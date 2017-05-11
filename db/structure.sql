--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.4
-- Dumped by pg_dump version 9.5.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: data; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA data;


--
-- Name: import; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA import;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = data, pg_catalog;

--
-- Name: get_qct_qda_history(character varying, date, character varying, date); Type: FUNCTION; Schema: data; Owner: -
--

CREATE FUNCTION get_qct_qda_history(character varying, date, character varying, date) RETURNS void
    LANGUAGE plpgsql
    AS $_$
        DECLARE rec record;
        DECLARE layer_type_query ALIAS for $1;
        DECLARE declaration_date_query ALIAS for $2;
        DECLARE county_fips_query ALIAS for $3;
        DECLARE layer_start_query ALIAS for $4;
        BEGIN
          -- loop over all datasets for a type and create a new temp table of the designations for that county for all available datasets
          FOR rec IN SELECT distinct data_table_name
            FROM public.data_sets AS d
            WHERE
              d.layer_type = layer_type_query AND
              d.start >= declaration_date_query - interval '5 years'
          -- start looping over data_table_names
          LOOP
            --make a temp table to store the aggregated values across the loop
            create table IF NOT EXISTS data.qct_qda_temp (
              gid SERIAL primary key,
              county_fips varchar,
              tract_fips varchar,
              data_table_name varchar,
              effective date,
              redesignated boolean,
              current_status varchar,
              status varchar,
              expires date
            );

            -- insert into the temp table the designations for a county_fips for all datasets
            -- including taking into account when the county_fips might have changed
            -- also do not include water tracts which are 99, e.g., 12009 - 99 - 0000
            EXECUTE FORMAT('
              -- then stick values into it
              INSERT INTO data.qct_qda_temp (
                county_fips,
                tract_fips,
                data_table_name,
                effective,
                redesignated,
                current_status,
                expires
              )
              (SELECT
                $2,
                t.tract_fips,
                $1 as data_table_name,
                t.effective,
                t.redesignated,
                t.current_status,
                t.expires
              FROM data.%s as t
                WHERE
                  (SUBSTRING(t.tract_fips from 0 for 6) = $2 OR
                  SUBSTRING(t.tract_fips from 0 for 6) = (select from_fips from data.county_changes where to_fips = $2)) AND
                  SUBSTRING(t.tract_fips from 6 for 2) != $3
              )', rec.data_table_name) using rec.data_table_name, county_fips_query, '99'::text;
          END LOOP;

          -- now, outside the loop, we will add stuff to the main qct_qda from the temp table created above

          -- determine which tracts were redesignated at some point in the last 5 years add those to the qct_qda table
          INSERT INTO data.qct_qda (
            county_fips,
            tract_fips,
            qda_id,
            qda_declaration,
            qda_publish
          )
          (select
            qda.county_fips,
            r_hist.tract_fips,
            qda.gid as qda_id,
            qda.declaration_date as qda_declaration,
            qda.effective as qda_publish
            from
            (select * from data.qda where effective = layer_start_query) as qda,
            (select substring(tract_fips from 0 for 6) as county_fips, tract_fips, true = any(array_agg(redesignated)) as is_r
              from data.qct_qda_temp
              where county_fips = county_fips_query
              group by tract_fips) as r_hist
          where qda.county_fips = county_fips_query and r_hist.is_r is true);

          -- determine when a tract was expired
          UPDATE data.qct_qda qct
          SET qct_max_expires = max_expires.expires_date
          FROM (
            select tract_fips, max(expires) as expires_date
            from data.qct_qda_temp where county_fips = county_fips_query
            group by tract_fips
            ) as max_expires
          WHERE qct.tract_fips = max_expires.tract_fips;

          -- determine current qnmc status by evaluation of its desgination statuses
          UPDATE data.qct_qda qct
          SET qct_current_status = qct_current.status
          FROM (
            select
            Q.tract_fips,
            case
              when Q.redesignated then 'redesignated'
              when Q.current_status = 'Qualified' then 'qualified'
              else 'not-qualified'
              end as status
              from (
                select t.*
                  from data.qct_qda_temp as t,
                  (select tract_fips, max(effective) as effective from data.qct_qda_temp where county_fips = county_fips_query group by tract_fips) as m
                  where t.tract_fips = m.tract_fips and t.effective = m.effective
              ) as Q
          ) as qct_current
          WHERE qct.tract_fips = qct_current.tract_fips;

          -- set qda designation dates for qdas that are now new qdas,  'not-qualified'
          UPDATE data.qct_qda as q
          set
            qda_designation = q.qda_declaration,
            expires = q.qda_declaration + interval '5 years'
          FROM (
            SELECT gid from data.qct_qda
            WHERE
              qct_current_status = 'not-qualified' or
              qct_max_expires <= qda_declaration and
              qct_current_status != 'redesignated' and
              qct_current_status != 'qualified'
          ) as qda_ready
          where q.gid = qda_ready.gid;

          -- set the future qdas for redeisgnated tracts
          UPDATE data.qct_qda as q
          set
            qda_designation = q.qct_max_expires,
            expires = q.qct_max_expires + interval '5 years'
          FROM (
            SELECT gid from data.qct_qda
            WHERE
              qct_current_status = 'redesignated'
          ) as qda_ready
          where q.gid = qda_ready.gid;

          -- add geometry columns for those that dont already have them
          UPDATE data.qct_qda as d
          SET geom = t.geom
          FROM import.master_tracts as t
          where d.tract_fips = t.geoid10 and d.geom IS NULL;

          -- drop the temp table since we dont need it any more for
          DROP TABLE IF EXISTS data.qct_qda_temp;

        END;
        $_$;


--
-- Name: get_qnmc_qda_history(character varying, date, character varying, date); Type: FUNCTION; Schema: data; Owner: -
--

CREATE FUNCTION get_qnmc_qda_history(character varying, date, character varying, date) RETURNS void
    LANGUAGE plpgsql
    AS $_$
        DECLARE rec record;
        DECLARE layer_type_query ALIAS for $1;
        DECLARE declaration_date_query ALIAS for $2;
        DECLARE county_fips_query ALIAS for $3;
        DECLARE layer_start_query ALIAS for $4;
        BEGIN
          -- loop over all datasets for a type and create a new temp table of the designations for that county for all available datasets
          FOR rec IN SELECT distinct data_table_name
            FROM public.data_sets AS d
            WHERE
              d.layer_type = layer_type_query AND
              d.start >= declaration_date_query - interval '5 years'
          -- start looping over data_table_names
          LOOP
            --make a temp table to store the aggregated values across the loop
            create table IF NOT EXISTS data.qnmc_qda_temp (
              gid SERIAL primary key,
              county_fips varchar,
              data_table_name varchar,
              effective date,
              income boolean,
              unemployment boolean,
              dda boolean,
              redesignated boolean,
              status varchar,
              expires date,
              has_omb boolean,
              omb_delineation varchar
            );

            -- insert into the temp table the designations for a county_fips for all datasets
            -- including taking into account when the county_fips might have changed
            EXECUTE FORMAT('
              -- then stick values into it
              INSERT INTO data.qnmc_qda_temp (
                county_fips,
                data_table_name,
                effective,
                income,
                unemployment,
                dda,
                redesignated,
                expires
              )
              (SELECT
                $2,
                $1 as data_table_name,
                d.effective,
                d.income,
                d.unemployment,
                d.dda,
                d.redesignated,
                d.expires
              FROM data.%s as d
                WHERE
                  d.county_fips = $2 OR
                  d.county_fips = (select from_fips from data.county_changes where to_fips = $2)
              )', rec.data_table_name) using rec.data_table_name, county_fips_query;

              -- add a boolean value to the temp table of the data_table had an omb_delineation column
              -- this was done because I couldn't get the next function to run correctly in the case when the table did not have omb_delineation
              EXECUTE FORMAT('
                UPDATE data.qnmc_qda_temp as qda_temp
                SET has_omb = has_omb.status
                FROM (
                  SELECT
                  CASE
                  WHEN
                    (SELECT count(column_name)
                      FROM information_schema.columns
                      WHERE table_name=$1 and column_name=$2) > 0
                    THEN TRUE
                  ELSE
                    FALSE
                  END as status
                ) as has_omb
                where qda_temp.county_fips = $3 AND
                qda_temp.data_table_name = $1
              ', rec.data_table_name) using rec.data_table_name, 'omb_delineation', county_fips_query;

              -- if the table had an omb_delineation column, apply that to omb_delineation to the row for that data table
              EXECUTE FORMAT('
                UPDATE data.qnmc_qda_temp as qda_temp
                  SET omb_delineation = omb.omb
                  FROM (
                    select
                    case
                      WHEN Q.has_omb IS TRUE
                        THEN (select omb_delineation from data.%s where county_fips = $1)
                      else
                        NULL
                      end as omb
                      from (select * from data.qnmc_qda_temp where county_fips = $1 and has_omb) as Q
                  ) as omb
                  WHERE qda_temp.county_fips = $1 AND
                  qda_temp.has_omb and
                  qda_temp.data_table_name = $2;
              ', rec.data_table_name) using county_fips_query, rec.data_table_name;
          END LOOP;

          -- now, outside the loop, we will add stuff to the main qnmc_qda from the temp table created above

          -- determine which counties were redesignated at some point in the last 5 years add those to the qnmc_qda table
          INSERT INTO data.qnmc_qda (
            county_fips,
            qda_id,
            qda_declaration,
            qda_publish
          )
          (select
            qda.county_fips,
            qda.gid as qda_id,
            qda.declaration_date as qda_declaration,
            qda.effective as qda_publish
            from
            (select * from data.qda where effective = layer_start_query) as qda,
            (select true = any(array(select redesignated from data.qnmc_qda_temp where county_fips = county_fips_query)) as is_r) as r_hist
          where qda.county_fips = county_fips_query and r_hist.is_r is true);

          -- determine when a county was expired
          UPDATE data.qnmc_qda qnmc
          SET qnmc_max_expires = max_expires.expires_date
          FROM (select max(expires) as expires_date from data.qnmc_qda_temp where county_fips = county_fips_query) as max_expires
          WHERE qnmc.county_fips = county_fips_query;

          -- determine current qnmc status by evaluation of its desgination statuses
          UPDATE data.qnmc_qda qnmc
          SET qnmc_current_status = qnmc_current.status
          FROM (
            select
            case
              when Q.redesignated then 'redesignated'
              when Q.income or Q.unemployment or Q.dda then 'qualified'
              else 'not-qualified'
              end as status
              from (select * from data.qnmc_qda_temp where county_fips = county_fips_query order by effective desc limit 1) as Q
          ) as qnmc_current
          WHERE qnmc.county_fips = county_fips_query;

          -- determine a countys current omb metrpolitan designation
          UPDATE data.qnmc_qda qnmc
          SET qnmc_current_omb = qnmc_current.omb
          FROM (select omb_delineation as omb from data.qnmc_qda_temp where county_fips = county_fips_query order by effective desc limit 1) as qnmc_current
          WHERE qnmc.county_fips = county_fips_query;

          -- set qda designation dates for qdas that are now new qdas,  'not-qualified'
          UPDATE data.qnmc_qda as q
          set
            qda_designation = q.qda_declaration,
            expires = q.qda_declaration + interval '5 years'
          FROM (
            SELECT gid from data.qnmc_qda
            WHERE
              qnmc_current_status = 'not-qualified' or
              qnmc_max_expires <= qda_declaration and
              qnmc_current_status != 'redesignated' and
              qnmc_current_status != 'qualified'
          ) as qda_ready
          where q.gid = qda_ready.gid;

          -- set the future qdas for redeisgnated counties
          UPDATE data.qnmc_qda as q
          set
            qda_designation = q.qnmc_max_expires,
            expires = q.qnmc_max_expires + interval '5 years'
          FROM (
            SELECT gid from data.qnmc_qda
            WHERE
              qnmc_current_status = 'redesignated'
          ) as qda_ready
          where q.gid = qda_ready.gid;

          -- add geometry columns for those that dont already have them
          UPDATE data.qnmc_qda as d
          SET geom = c.geom
          FROM import.master_counties as c
          where d.county_fips = c.geoid10 and d.geom IS NULL;

          -- drop the temp table since we dont need it any more for
          DROP TABLE IF EXISTS data.qnmc_qda_temp;

        END;
        $_$;


--
-- Name: update_qct_brac(character varying, date); Type: FUNCTION; Schema: data; Owner: -
--

CREATE FUNCTION update_qct_brac(character varying, date) RETURNS void
    LANGUAGE plpgsql
    AS $_$
          DECLARE tablename ALIAS FOR $1;
          DECLARE publish_date ALIAS FOR $2;
            BEGIN
              EXECUTE FORMAT('
                -- append the raw geometries to the input qct table and index them
                DROP INDEX IF EXISTS data.' || tablename || '_raw_gix;
                ALTER TABLE data.' || tablename || ' DROP COLUMN IF EXISTS raw_geom;
                ALTER TABLE data.' || tablename || ' ADD COLUMN raw_geom geometry(' || 'MULTIPOLYGON' || ', 4326);
                UPDATE data.' || tablename || ' as d
                  SET raw_geom = t.geom
                  FROM import.raw_tracts as t
                  WHERE d.tract_fips = t.geoid10
                  AND t.aland10 > 0;
                -- add spatial index
                CREATE INDEX ' || tablename || '_raw_gix ON data.' || tablename || ' USING GIST (raw_geom);

                -- perform first brac geometry query - getting any that contain or intersect and sticking that on data.qct_brac
                INSERT INTO data.qct_brac (
                  brac_id, brac_sba_name, tract_fips, effective, expires, geom, raw_geom
                )
                (SELECT
                  b.gid                 as brac_id,
                  b.sba_name            as brac_sba_name,
                  t.tract_fips          as tract_fips,
                  b.effective           as effective,
                  b.expires             as expires,
                  t.geom                as geom,
                  t.raw_geom            as raw_geom
                FROM
                  data.brac as b,
                  data.' || tablename || ' as t
                  WHERE
                    (ST_CONTAINS(t.raw_geom, b.geom) OR
                    ST_INTERSECTS(t.raw_geom, b.geom)) AND
                    t.current_status != $3
                  );

                -- perform the second adjacency query - inserting into data.qct_brac any counties that touch the ones we just added
                INSERT INTO data.qct_brac (
                  brac_id, brac_sba_name, tract_fips, effective, expires, geom
                )
                (SELECT
                  qct_brac_sq.brac_id         as brac_id,
                  qct_brac_sq.brac_sba_name   as brac_sba_name,
                  t1.tract_fips               as tract_fips,
                  qct_brac_sq.effective       as effective,
                  qct_brac_sq.expires         as expires,
                  t1.geom                     as geom
                  FROM
                      data.' || tablename || ' as t1,
                      (SELECT * FROM data.qct_brac) AS qct_brac_sq
                    WHERE
                      ST_TOUCHES(t1.raw_geom, qct_brac_sq.raw_geom) AND
                      t1.current_status != $3
                    );

                -- add the publish data and table name fields
                UPDATE data.qct_brac
                SET
                  qct_data_table = $1,
                  publish_date = $2
                WHERE publish_date IS NULL;

                -- add the brac boolean designation based on join to the other attributes
                UPDATE data.qct_brac d
                SET
                  brac = TRUE
                  FROM
                    (SELECT tract_fips
                      FROM data.' || tablename || ' as t3
                      WHERE
                        current_status != $3) as tracts_not_q
                WHERE d.tract_fips = tracts_not_q.tract_fips;

                -- dump the raw_geom column from qct_brac
                UPDATE data.qct_brac
                SET raw_geom = null;

                --drop the raw_geom column from the qnmc table since its not needed moving forward
                ALTER TABLE data.' || tablename || ' DROP COLUMN IF EXISTS raw_geom;
                DROP INDEX IF EXISTS data.' || tablename || '_raw_gix;
              ') using tablename, publish_date, 'Qualified';
            END
          $_$;


--
-- Name: update_qnmc_brac(character varying, date); Type: FUNCTION; Schema: data; Owner: -
--

CREATE FUNCTION update_qnmc_brac(character varying, date) RETURNS void
    LANGUAGE plpgsql
    AS $_$
          DECLARE tablename ALIAS FOR $1;
          DECLARE publish_date ALIAS FOR $2;
            BEGIN
              EXECUTE FORMAT('
                -- append the raw geometries to the input qnmc table and index them
                DROP INDEX IF EXISTS data.' || tablename || '_raw_gix;
                ALTER TABLE data.' || tablename || ' DROP COLUMN IF EXISTS raw_geom;
                ALTER TABLE data.' || tablename || ' ADD COLUMN raw_geom geometry(' || 'MULTIPOLYGON' || ', 4326);
                UPDATE data.' || tablename || ' as d
                  SET raw_geom = c.geom
                  FROM import.raw_counties as c
                  WHERE d.county_fips = c.geoid10
                  AND c.aland10 > 0;
                -- add spatial index
                CREATE INDEX ' || tablename || '_raw_gix ON data.' || tablename || ' USING GIST (raw_geom);

                -- perform first brac geometry query - getting any that contain or intersect and sticking that on data.qnmc_brac
                -- put only pick counties that are not qualified, are not redesignated, and are Non-metropolitan
                INSERT INTO data.qnmc_brac (
                  brac_id, brac_sba_name, county_fips, effective, expires, geom, raw_geom
                )
                (SELECT
                  b.gid                 as brac_id,
                  b.sba_name            as brac_sba_name,
                  c.county_fips         as county_fips,
                  b.effective           as effective,
                  b.expires             as expires,
                  c.geom                as geom,
                  c.raw_geom            as raw_geom
                FROM
                  data.brac as b,
                  data.' || tablename || ' as c
                  WHERE
                    (ST_CONTAINS(c.raw_geom, b.geom)   OR
                    ST_INTERSECTS(c.raw_geom, b.geom)) AND
                    c.income       IS FALSE AND
                    c.unemployment IS FALSE AND
                    c.dda          IS FALSE AND
                    c.omb_delineation = $3
                  );

                -- perform the second adjacency query - inserting into data.qnmc_brac any counties that touch the ones we just added
                INSERT INTO data.qnmc_brac (
                  brac_id, brac_sba_name, county_fips, effective, expires, geom
                )
                (SELECT
                  qnmc_brac_sq.brac_id         as brac_id,
                  qnmc_brac_sq.brac_sba_name   as brac_sba_name,
                  c1.county_fips               as county_fips,
                  qnmc_brac_sq.effective       as effective,
                  qnmc_brac_sq.expires         as expires,
                  c1.geom                      as geom
                  FROM
                      data.' || tablename || ' as c1,
                      (SELECT * FROM data.qnmc_brac) AS qnmc_brac_sq
                    WHERE
                      ST_TOUCHES(c1.raw_geom, qnmc_brac_sq.raw_geom) AND
                      c1.income       IS FALSE AND
                      c1.unemployment IS FALSE AND
                      c1.dda          IS FALSE AND
                      c1.omb_delineation = $3
                    );

                -- add the publish data and table name fields
                UPDATE data.qnmc_brac
                SET
                  qnmc_data_table = $1,
                  publish_date = $2
                WHERE publish_date IS NULL;

                -- add the brac boolean designation based on join to the other attributes
                UPDATE data.qnmc_brac d
                SET
                  brac = TRUE
                  FROM
                    (SELECT county_fips
                      FROM data.' || tablename || ' as c3
                      WHERE
                        income       IS FALSE AND
                        unemployment IS FALSE AND
                        dda          IS FALSE AND
                        omb_delineation = $3) AS counties_not_q
                WHERE d.county_fips = counties_not_q.county_fips;

                -- dump the raw_geom column from qnmc_brac
                UPDATE data.qnmc_brac
                SET raw_geom = null;

                --drop the raw_geom column from the qnmc table since its not needed moving forward
                ALTER TABLE data.' || tablename || ' DROP COLUMN IF EXISTS raw_geom;
                DROP INDEX IF EXISTS data.' || tablename || '_raw_gix;
              ') using tablename, publish_date, 'Non-metropolitan';
            END
          $_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: brac; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE brac (
    gid integer NOT NULL,
    sba_name character varying,
    county character varying,
    st_name character varying,
    fac_type character varying,
    closure character varying,
    geom public.geometry(MultiPolygon,4326),
    effective date,
    expires date
);


--
-- Name: brac_2016_10_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE brac_2016_10_01 (
    gid integer,
    sba_name character varying(36),
    county character varying(36),
    st_name character varying(25),
    fac_type character varying(25),
    closure character varying(15),
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: brac_gid_seq; Type: SEQUENCE; Schema: data; Owner: -
--

CREATE SEQUENCE brac_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brac_gid_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: -
--

ALTER SEQUENCE brac_gid_seq OWNED BY brac.gid;


--
-- Name: county_changes; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE county_changes (
    gid integer NOT NULL,
    from_fips character varying,
    from_county_name character varying,
    from_geom public.geometry(MultiPolygon,4326),
    to_fips character varying,
    to_county_name character varying,
    to_geom public.geometry(MultiPolygon,4326),
    effective date,
    updated date
);


--
-- Name: county_changes_gid_seq; Type: SEQUENCE; Schema: data; Owner: -
--

CREATE SEQUENCE county_changes_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: county_changes_gid_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: -
--

ALTER SEQUENCE county_changes_gid_seq OWNED BY county_changes.gid;


--
-- Name: indian_lands; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE indian_lands (
    gid integer,
    objectid integer,
    id numeric,
    indian character varying(7),
    state character varying(2),
    census character varying(7),
    gnis integer,
    name character varying(62),
    type character varying(37),
    class character varying(54),
    recognitio character varying(7),
    land_area numeric,
    water_area numeric,
    shape_leng numeric,
    shape_area numeric,
    geom public.geometry(MultiPolygon,4326),
    effective date DEFAULT ('now'::text)::date NOT NULL,
    expires date
);


--
-- Name: master_county_names; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE master_county_names (
    gid integer NOT NULL,
    state character(2),
    state_fips character(2),
    county_fips character(3),
    county character varying,
    class_fips character(2)
);


--
-- Name: master_county_names_gid_seq; Type: SEQUENCE; Schema: data; Owner: -
--

CREATE SEQUENCE master_county_names_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_county_names_gid_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: -
--

ALTER SEQUENCE master_county_names_gid_seq OWNED BY master_county_names.gid;


--
-- Name: qct_2012_10_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qct_2012_10_01 (
    gid integer,
    tract_fips character varying,
    state character varying,
    city character varying,
    county character varying,
    current_status character varying,
    redesignated boolean,
    expires date,
    geom public.geometry(MultiPolygon,4326),
    effective date DEFAULT ('now'::text)::date NOT NULL
);


--
-- Name: qct_2015_01_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qct_2015_01_01 (
    gid integer,
    tract_fips character varying,
    state character varying,
    city character varying,
    county character varying,
    prior_status character varying,
    current_status character varying,
    redesignated boolean,
    expires date,
    geom public.geometry(MultiPolygon,4326),
    effective date DEFAULT ('now'::text)::date NOT NULL
);


--
-- Name: qct_2016_03_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qct_2016_03_01 (
    gid integer,
    tract_fips character varying,
    county character varying,
    state character varying,
    omb_delineation character varying,
    prior_status character varying,
    current_status character varying,
    change boolean,
    redesignated boolean,
    expires date,
    geom public.geometry(MultiPolygon,4326),
    effective date DEFAULT ('now'::text)::date NOT NULL
);


--
-- Name: qct_2017_01_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qct_2017_01_01 (
    gid integer,
    tract_fips character varying,
    county character varying,
    state character varying,
    omb_delineation character varying,
    prior_status character varying,
    current_status character varying,
    status_change boolean,
    redesignated boolean,
    expires date,
    geom public.geometry(MultiPolygon,4326),
    effective date DEFAULT ('now'::text)::date NOT NULL
);


--
-- Name: qct_brac; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qct_brac (
    gid integer NOT NULL,
    brac_id integer,
    brac_sba_name character varying,
    tract_fips character varying,
    effective date,
    expires date,
    publish_date date,
    qct_data_table character varying,
    brac boolean DEFAULT false,
    geom public.geometry(MultiPolygon,4326),
    raw_geom public.geometry(MultiPolygon,4326)
);


--
-- Name: qct_brac_gid_seq; Type: SEQUENCE; Schema: data; Owner: -
--

CREATE SEQUENCE qct_brac_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qct_brac_gid_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: -
--

ALTER SEQUENCE qct_brac_gid_seq OWNED BY qct_brac.gid;


--
-- Name: qct_qda; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qct_qda (
    gid integer NOT NULL,
    county_fips character varying,
    tract_fips character varying,
    qda_id integer,
    qda_publish date,
    qda_declaration date,
    qct_max_expires date,
    qct_current_status character varying,
    qda_designation date,
    expires date,
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: qct_qda_gid_seq; Type: SEQUENCE; Schema: data; Owner: -
--

CREATE SEQUENCE qct_qda_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qct_qda_gid_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: -
--

ALTER SEQUENCE qct_qda_gid_seq OWNED BY qct_qda.gid;


--
-- Name: qda; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qda (
    gid integer NOT NULL,
    disaster_state character varying,
    fema_code smallint,
    disaster_type character varying,
    declaration_date date,
    incident_description character varying,
    incidence_period character varying,
    amendment smallint,
    state character varying,
    county character varying,
    state_fips character(2),
    county_fips_3 character(3),
    effective date,
    county_fips character(5),
    import date,
    import_table character varying,
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: qda_2016_11_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qda_2016_11_01 (
    gid integer,
    disaster_state character varying,
    fema_code smallint,
    disaster_type character varying,
    declaration_date date,
    incident_description character varying,
    incidence_period character varying,
    amendment smallint,
    state character varying,
    county character varying,
    state_fips character(2),
    county_fips_3 character(3),
    effective date,
    county_fips character(5),
    import date DEFAULT ('now'::text)::date,
    import_table character varying DEFAULT 'qda_2016_11_01'::character varying
);


--
-- Name: qda_2017_03_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qda_2017_03_01 (
    gid integer,
    disaster_state character varying,
    fema_code smallint,
    disaster_type character varying,
    declaration_date date,
    incident_description character varying,
    incidence_period character varying,
    amendment smallint,
    state character varying,
    county character varying,
    state_fips character(2),
    county_fips_3 character(3),
    effective date,
    county_fips character(5),
    import date DEFAULT ('now'::text)::date,
    import_table character varying DEFAULT 'qda_2017_03_01'::character varying
);


--
-- Name: qda_2017_04_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qda_2017_04_01 (
    gid integer,
    disaster_state character varying,
    fema_code smallint,
    disaster_type character varying,
    declaration_date date,
    incident_description character varying,
    incidence_period character varying,
    amendment smallint,
    state character varying,
    county character varying,
    state_fips character(2),
    county_fips_3 character(3),
    effective date,
    county_fips character(5),
    import date DEFAULT ('now'::text)::date,
    import_table character varying DEFAULT 'qda_2017_04_01'::character varying
);


--
-- Name: qda_2017_05_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qda_2017_05_01 (
    gid integer,
    disaster_state character varying,
    fema_code smallint,
    disaster_type character varying,
    declaration_date date,
    incident_description character varying,
    incidence_period character varying,
    amendment smallint,
    state character varying,
    county character varying,
    state_fips character(2),
    county_fips_3 character(3),
    effective date,
    county_fips character(5),
    import date DEFAULT ('now'::text)::date,
    import_table character varying DEFAULT 'qda_2017_05_01'::character varying
);


--
-- Name: qda_gid_seq; Type: SEQUENCE; Schema: data; Owner: -
--

CREATE SEQUENCE qda_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qda_gid_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: -
--

ALTER SEQUENCE qda_gid_seq OWNED BY qda.gid;


--
-- Name: qnmc_2013_01_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qnmc_2013_01_01 (
    gid integer,
    county_fips character varying,
    county character varying,
    state character varying,
    income boolean,
    unemployment boolean,
    dda boolean,
    redesignated boolean,
    expires date,
    january2013_status character varying,
    geom public.geometry(MultiPolygon,4326),
    effective date DEFAULT ('now'::text)::date NOT NULL,
    qda boolean DEFAULT false
);


--
-- Name: qnmc_2013_05_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qnmc_2013_05_01 (
    gid integer,
    county_fips character varying,
    county character varying,
    state character varying,
    income boolean,
    unemployment boolean,
    dda boolean,
    redesignated boolean,
    expires date,
    january2013_status character varying,
    may2013_status character varying,
    geom public.geometry(MultiPolygon,4326),
    effective date DEFAULT ('now'::text)::date NOT NULL,
    qda boolean DEFAULT false
);


--
-- Name: qnmc_2014_01_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qnmc_2014_01_01 (
    gid integer,
    county_fips character varying,
    county character varying,
    state character varying,
    income boolean,
    unemployment boolean,
    dda boolean,
    redesignated boolean,
    expires date,
    jan_2014_status character varying,
    geom public.geometry(MultiPolygon,4326),
    effective date DEFAULT ('now'::text)::date NOT NULL,
    qda boolean DEFAULT false
);


--
-- Name: qnmc_2014_05_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qnmc_2014_05_01 (
    gid integer,
    county_fips character varying,
    county character varying,
    state character varying,
    income boolean,
    unemployment boolean,
    dda boolean,
    redesignated boolean,
    expires date,
    jan_2014_status character varying,
    may_2014_status character varying,
    geom public.geometry(MultiPolygon,4326),
    effective date DEFAULT ('now'::text)::date NOT NULL,
    qda boolean DEFAULT false
);


--
-- Name: qnmc_2015_01_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qnmc_2015_01_01 (
    gid integer,
    county_fips character varying,
    county character varying,
    state character varying,
    income boolean,
    unemployment boolean,
    dda boolean,
    redesignated boolean,
    expires date,
    jan_2015_status character varying,
    geom public.geometry(MultiPolygon,4326),
    effective date DEFAULT ('now'::text)::date NOT NULL,
    qda boolean DEFAULT false
);


--
-- Name: qnmc_2015_07_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qnmc_2015_07_01 (
    gid integer,
    county_fips character varying,
    county character varying,
    state character(2),
    income boolean,
    unemployment boolean,
    dda boolean,
    redesignated boolean,
    expires date,
    income_ratio double precision,
    state_ratio_2014 double precision,
    us_ratio_2014 double precision,
    state_ratio_2013 double precision,
    us_ratio_2013 double precision,
    state_ratio_2012 real,
    us_ratio_2012 double precision,
    omb_delineation character varying,
    jan_2015_status character varying,
    july_2015_status_new_status character varying,
    geom public.geometry(MultiPolygon,4326),
    effective date DEFAULT ('now'::text)::date NOT NULL,
    qda boolean DEFAULT false
);


--
-- Name: qnmc_2016_03_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qnmc_2016_03_01 (
    gid integer,
    county_fips character varying,
    county character varying,
    state character varying,
    income boolean,
    unemployment boolean,
    dda boolean,
    redesignated boolean,
    expires date,
    march2016_status character varying,
    geom public.geometry(MultiPolygon,4326),
    effective date DEFAULT ('now'::text)::date NOT NULL,
    qda boolean DEFAULT false
);


--
-- Name: qnmc_2016_07_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qnmc_2016_07_01 (
    gid integer,
    county_fips character varying,
    county character varying,
    state character varying,
    income boolean,
    unemployment boolean,
    dda boolean,
    redesignated boolean,
    expires date,
    march2016_status character varying,
    july2016_status1 character varying,
    july2016_statusfinal character varying,
    omb_delineation character varying,
    ratio_income2016 double precision,
    march2016status character varying,
    march2016_statuscode smallint,
    current_status smallint,
    state_code smallint,
    _2015_cntyur real,
    _2015_stur real,
    _2015_usur real,
    _2015_st_ratio real,
    _2015_us_ratio real,
    _2014_cntyur real,
    _2014_stur real,
    _2014_usur real,
    _2014_st_ratio real,
    _2014_us_ratio real,
    _2013_cntyur real,
    _2013_stur real,
    _2013_usur real,
    _2013_st_ratio real,
    _2013_us_ratio real,
    qunemp_2016 smallint,
    rqbls_2015 smallint,
    rqbls_2014 smallint,
    new_status_1 smallint,
    new_status_2 smallint,
    geom public.geometry(MultiPolygon,4326),
    effective date DEFAULT ('now'::text)::date NOT NULL,
    qda boolean DEFAULT false
);


--
-- Name: qnmc_2017_03_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qnmc_2017_03_01 (
    gid integer,
    county_fips character varying,
    county character varying,
    state character varying,
    march_2017_status_current character varying,
    median_household_income_ratio_2016 double precision,
    state_unemployment_ratio_2015 real,
    us_unemployment_ratio_2015 real,
    omb_delineation character varying,
    q_inc_2017 smallint,
    initial_analysis character varying,
    q_dda_2017 smallint,
    july_2016_status_previous character varying,
    income boolean,
    unemployment boolean,
    dda boolean,
    redesignated boolean,
    expires date,
    geom public.geometry(MultiPolygon,4326),
    effective date DEFAULT ('now'::text)::date NOT NULL,
    qda boolean DEFAULT false
);


--
-- Name: qnmc_brac; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qnmc_brac (
    gid integer NOT NULL,
    brac_id integer,
    brac_sba_name character varying,
    county_fips character varying,
    effective date,
    expires date,
    publish_date date,
    qnmc_data_table character varying,
    brac boolean DEFAULT false,
    geom public.geometry(MultiPolygon,4326),
    raw_geom public.geometry(MultiPolygon,4326)
);


--
-- Name: qnmc_brac_gid_seq; Type: SEQUENCE; Schema: data; Owner: -
--

CREATE SEQUENCE qnmc_brac_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qnmc_brac_gid_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: -
--

ALTER SEQUENCE qnmc_brac_gid_seq OWNED BY qnmc_brac.gid;


--
-- Name: qnmc_qda; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qnmc_qda (
    gid integer NOT NULL,
    county_fips character varying,
    qda_id integer,
    qda_publish date,
    qda_declaration date,
    qnmc_max_expires date,
    qnmc_current_status character varying,
    qnmc_current_omb character varying,
    qda_designation date,
    expires date,
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: qnmc_qda_gid_seq; Type: SEQUENCE; Schema: data; Owner: -
--

CREATE SEQUENCE qnmc_qda_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qnmc_qda_gid_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: -
--

ALTER SEQUENCE qnmc_qda_gid_seq OWNED BY qnmc_qda.gid;


SET search_path = import, pg_catalog;

--
-- Name: brac_2016_10_01; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE brac_2016_10_01 (
    gid integer NOT NULL,
    sba_name character varying(36),
    county character varying(36),
    st_name character varying(25),
    fac_type character varying(25),
    closure character varying(15),
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: brac_2016_10_01_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE brac_2016_10_01_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brac_2016_10_01_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE brac_2016_10_01_gid_seq OWNED BY brac_2016_10_01.gid;


--
-- Name: indianlands_2014; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE indianlands_2014 (
    gid integer NOT NULL,
    objectid integer,
    id numeric,
    indian character varying(7),
    state character varying(2),
    census character varying(7),
    gnis integer,
    name character varying(62),
    type character varying(37),
    class character varying(54),
    recognitio character varying(7),
    land_area numeric,
    water_area numeric,
    shape_leng numeric,
    shape_area numeric,
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: indianlands_2014_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE indianlands_2014_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: indianlands_2014_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE indianlands_2014_gid_seq OWNED BY indianlands_2014.gid;


--
-- Name: master_counties; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE master_counties (
    gid integer NOT NULL,
    feature_gid integer,
    statefp10 character varying(2),
    countyfp10 character varying(3),
    countyns10 character varying(8),
    geoid10 character varying(5),
    name10 character varying(100),
    namelsad10 character varying(100),
    lsad10 character varying(2),
    classfp10 character varying(2),
    mtfcc10 character varying(5),
    csafp10 character varying(3),
    cbsafp10 character varying(5),
    metdivfp10 character varying(5),
    funcstat10 character varying(1),
    aland10 double precision,
    awater10 double precision,
    intptlat10 character varying(12),
    intptlon10 character varying(12),
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: master_counties_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE master_counties_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_counties_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE master_counties_gid_seq OWNED BY master_counties.gid;


--
-- Name: master_tracts; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE master_tracts (
    gid integer NOT NULL,
    feature_gid integer,
    statefp10 character varying(2),
    countyfp10 character varying(3),
    tractce10 character varying(6),
    geoid10 character varying(11),
    name10 character varying(7),
    namelsad10 character varying(20),
    mtfcc10 character varying(5),
    funcstat10 character varying(1),
    aland10 double precision,
    awater10 double precision,
    intptlat10 character varying(12),
    intptlon10 character varying(12),
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: master_tracts_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE master_tracts_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_tracts_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE master_tracts_gid_seq OWNED BY master_tracts.gid;


--
-- Name: qct_2012_10_01; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE qct_2012_10_01 (
    gid integer NOT NULL,
    tract_fips character varying,
    state character varying,
    city character varying,
    county character varying,
    current_status character varying,
    redesignated boolean,
    expires date
);


--
-- Name: qct_2012_10_01_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE qct_2012_10_01_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qct_2012_10_01_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE qct_2012_10_01_gid_seq OWNED BY qct_2012_10_01.gid;


--
-- Name: qct_2015_01_01; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE qct_2015_01_01 (
    gid integer NOT NULL,
    tract_fips character varying,
    state character varying,
    city character varying,
    county character varying,
    prior_status character varying,
    current_status character varying,
    redesignated boolean,
    expires date
);


--
-- Name: qct_2015_01_01_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE qct_2015_01_01_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qct_2015_01_01_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE qct_2015_01_01_gid_seq OWNED BY qct_2015_01_01.gid;


--
-- Name: qct_2016_03_01; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE qct_2016_03_01 (
    gid integer NOT NULL,
    tract_fips character varying,
    county character varying,
    state character varying,
    omb_delineation character varying,
    prior_status character varying,
    current_status character varying,
    change boolean,
    redesignated boolean,
    expires date
);


--
-- Name: qct_2016_03_01_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE qct_2016_03_01_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qct_2016_03_01_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE qct_2016_03_01_gid_seq OWNED BY qct_2016_03_01.gid;


--
-- Name: qct_2017_01_01; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE qct_2017_01_01 (
    gid integer NOT NULL,
    tract_fips character varying,
    county character varying,
    state character varying,
    omb_delineation character varying,
    prior_status character varying,
    current_status character varying,
    status_change boolean,
    redesignated boolean,
    expires date
);


--
-- Name: qct_2017_01_01_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE qct_2017_01_01_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qct_2017_01_01_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE qct_2017_01_01_gid_seq OWNED BY qct_2017_01_01.gid;


--
-- Name: qda_2016_11_01; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE qda_2016_11_01 (
    gid integer NOT NULL,
    disaster_state character varying,
    fema_code smallint,
    disaster_type character varying,
    declaration_date date,
    incident_description character varying,
    incidence_period character varying,
    amendment smallint,
    state character varying,
    county character varying,
    state_fips character(2),
    county_fips_3 character(3)
);


--
-- Name: qda_2016_11_01_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE qda_2016_11_01_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qda_2016_11_01_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE qda_2016_11_01_gid_seq OWNED BY qda_2016_11_01.gid;


--
-- Name: qda_2017_03_01; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE qda_2017_03_01 (
    gid integer NOT NULL,
    disaster_state character varying,
    fema_code smallint,
    disaster_type character varying,
    declaration_date date,
    incident_description character varying,
    incidence_period character varying,
    amendment smallint,
    state character varying,
    county character varying,
    state_fips character(2),
    county_fips_3 character(3)
);


--
-- Name: qda_2017_03_01_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE qda_2017_03_01_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qda_2017_03_01_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE qda_2017_03_01_gid_seq OWNED BY qda_2017_03_01.gid;


--
-- Name: qda_2017_04_01; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE qda_2017_04_01 (
    gid integer NOT NULL,
    disaster_state character varying,
    fema_code smallint,
    disaster_type character varying,
    declaration_date date,
    incident_description character varying,
    incidence_period character varying,
    amendment smallint,
    state character varying,
    county character varying,
    state_fips character(2),
    county_fips_3 character(3)
);


--
-- Name: qda_2017_04_01_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE qda_2017_04_01_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qda_2017_04_01_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE qda_2017_04_01_gid_seq OWNED BY qda_2017_04_01.gid;


--
-- Name: qda_2017_05_01; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE qda_2017_05_01 (
    gid integer NOT NULL,
    disaster_state character varying,
    fema_code smallint,
    disaster_type character varying,
    declaration_date date,
    incident_description character varying,
    incidence_period character varying,
    amendment smallint,
    state character varying,
    county character varying,
    state_fips character(2),
    county_fips_3 character(3)
);


--
-- Name: qda_2017_05_01_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE qda_2017_05_01_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qda_2017_05_01_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE qda_2017_05_01_gid_seq OWNED BY qda_2017_05_01.gid;


--
-- Name: qnmc_2013_01_01; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE qnmc_2013_01_01 (
    gid integer NOT NULL,
    county_fips character varying,
    county character varying,
    state character varying,
    income boolean,
    unemployment boolean,
    dda boolean,
    redesignated boolean,
    expires date,
    january2013_status character varying
);


--
-- Name: qnmc_2013_01_01_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE qnmc_2013_01_01_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qnmc_2013_01_01_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE qnmc_2013_01_01_gid_seq OWNED BY qnmc_2013_01_01.gid;


--
-- Name: qnmc_2013_05_01; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE qnmc_2013_05_01 (
    gid integer NOT NULL,
    county_fips character varying,
    county character varying,
    state character varying,
    income boolean,
    unemployment boolean,
    dda boolean,
    redesignated boolean,
    expires date,
    january2013_status character varying,
    may2013_status character varying
);


--
-- Name: qnmc_2013_05_01_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE qnmc_2013_05_01_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qnmc_2013_05_01_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE qnmc_2013_05_01_gid_seq OWNED BY qnmc_2013_05_01.gid;


--
-- Name: qnmc_2014_01_01; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE qnmc_2014_01_01 (
    gid integer NOT NULL,
    county_fips character varying,
    county character varying,
    state character varying,
    income boolean,
    unemployment boolean,
    dda boolean,
    redesignated boolean,
    expires date,
    jan_2014_status character varying
);


--
-- Name: qnmc_2014_01_01_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE qnmc_2014_01_01_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qnmc_2014_01_01_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE qnmc_2014_01_01_gid_seq OWNED BY qnmc_2014_01_01.gid;


--
-- Name: qnmc_2014_05_01; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE qnmc_2014_05_01 (
    gid integer NOT NULL,
    county_fips character varying,
    county character varying,
    state character varying,
    income boolean,
    unemployment boolean,
    dda boolean,
    redesignated boolean,
    expires date,
    jan_2014_status character varying,
    may_2014_status character varying
);


--
-- Name: qnmc_2014_05_01_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE qnmc_2014_05_01_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qnmc_2014_05_01_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE qnmc_2014_05_01_gid_seq OWNED BY qnmc_2014_05_01.gid;


--
-- Name: qnmc_2015_01_01; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE qnmc_2015_01_01 (
    gid integer NOT NULL,
    county_fips character varying,
    county character varying,
    state character varying,
    income boolean,
    unemployment boolean,
    dda boolean,
    redesignated boolean,
    expires date,
    jan_2015_status character varying
);


--
-- Name: qnmc_2015_01_01_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE qnmc_2015_01_01_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qnmc_2015_01_01_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE qnmc_2015_01_01_gid_seq OWNED BY qnmc_2015_01_01.gid;


--
-- Name: qnmc_2015_07_01; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE qnmc_2015_07_01 (
    gid integer NOT NULL,
    county_fips character varying,
    county character varying,
    state character(2),
    income boolean,
    unemployment boolean,
    dda boolean,
    redesignated boolean,
    expires date,
    income_ratio double precision,
    state_ratio_2014 double precision,
    us_ratio_2014 double precision,
    state_ratio_2013 double precision,
    us_ratio_2013 double precision,
    state_ratio_2012 real,
    us_ratio_2012 double precision,
    omb_delineation character varying,
    jan_2015_status character varying,
    july_2015_status_new_status character varying
);


--
-- Name: qnmc_2015_07_01_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE qnmc_2015_07_01_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qnmc_2015_07_01_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE qnmc_2015_07_01_gid_seq OWNED BY qnmc_2015_07_01.gid;


--
-- Name: qnmc_2016_03_01; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE qnmc_2016_03_01 (
    gid integer NOT NULL,
    county_fips character varying,
    county character varying,
    state character varying,
    income boolean,
    unemployment boolean,
    dda boolean,
    redesignated boolean,
    expires date,
    march2016_status character varying
);


--
-- Name: qnmc_2016_03_01_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE qnmc_2016_03_01_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qnmc_2016_03_01_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE qnmc_2016_03_01_gid_seq OWNED BY qnmc_2016_03_01.gid;


--
-- Name: qnmc_2016_07_01; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE qnmc_2016_07_01 (
    gid integer NOT NULL,
    county_fips character varying,
    county character varying,
    state character varying,
    income boolean,
    unemployment boolean,
    dda boolean,
    redesignated boolean,
    expires date,
    march2016_status character varying,
    july2016_status1 character varying,
    july2016_statusfinal character varying,
    omb_delineation character varying,
    ratio_income2016 double precision,
    march2016status character varying,
    march2016_statuscode smallint,
    current_status smallint,
    state_code smallint,
    _2015_cntyur real,
    _2015_stur real,
    _2015_usur real,
    _2015_st_ratio real,
    _2015_us_ratio real,
    _2014_cntyur real,
    _2014_stur real,
    _2014_usur real,
    _2014_st_ratio real,
    _2014_us_ratio real,
    _2013_cntyur real,
    _2013_stur real,
    _2013_usur real,
    _2013_st_ratio real,
    _2013_us_ratio real,
    qunemp_2016 smallint,
    rqbls_2015 smallint,
    rqbls_2014 smallint,
    new_status_1 smallint,
    new_status_2 smallint
);


--
-- Name: qnmc_2016_07_01_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE qnmc_2016_07_01_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qnmc_2016_07_01_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE qnmc_2016_07_01_gid_seq OWNED BY qnmc_2016_07_01.gid;


--
-- Name: qnmc_2017_03_01; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE qnmc_2017_03_01 (
    gid integer NOT NULL,
    county_fips character varying,
    county character varying,
    state character varying,
    march_2017_status_current character varying,
    median_household_income_ratio_2016 double precision,
    state_unemployment_ratio_2015 real,
    us_unemployment_ratio_2015 real,
    omb_delineation character varying,
    q_inc_2017 smallint,
    initial_analysis character varying,
    q_dda_2017 smallint,
    july_2016_status_previous character varying,
    income boolean,
    unemployment boolean,
    dda boolean,
    redesignated boolean,
    expires date
);


--
-- Name: qnmc_2017_03_01_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE qnmc_2017_03_01_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qnmc_2017_03_01_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE qnmc_2017_03_01_gid_seq OWNED BY qnmc_2017_03_01.gid;


--
-- Name: raw_counties; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE raw_counties (
    gid integer NOT NULL,
    feature_gid integer,
    statefp10 character varying(2),
    countyfp10 character varying(3),
    countyns10 character varying(8),
    geoid10 character varying(5),
    name10 character varying(100),
    namelsad10 character varying(100),
    lsad10 character varying(2),
    classfp10 character varying(2),
    mtfcc10 character varying(5),
    csafp10 character varying(3),
    cbsafp10 character varying(5),
    metdivfp10 character varying(5),
    funcstat10 character varying(1),
    aland10 double precision,
    awater10 double precision,
    intptlat10 character varying(12),
    intptlon10 character varying(12),
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: raw_counties_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE raw_counties_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: raw_counties_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE raw_counties_gid_seq OWNED BY raw_counties.gid;


--
-- Name: raw_tracts; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE raw_tracts (
    gid integer NOT NULL,
    feature_gid integer,
    statefp10 character varying(2),
    countyfp10 character varying(3),
    tractce10 character varying(6),
    geoid10 character varying(11),
    name10 character varying(7),
    namelsad10 character varying(20),
    mtfcc10 character varying(5),
    funcstat10 character varying(1),
    aland10 double precision,
    awater10 double precision,
    intptlat10 character varying(12),
    intptlon10 character varying(12),
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: raw_tracts_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE raw_tracts_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: raw_tracts_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE raw_tracts_gid_seq OWNED BY raw_tracts.gid;


SET search_path = public, pg_catalog;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: brac; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW brac AS
 SELECT d.gid,
    d.sba_name,
    d.county,
    d.st_name,
    d.fac_type,
    d.closure,
    d.geom,
    d.effective,
    d.expires
   FROM data.brac d
  WITH NO DATA;


--
-- Name: data_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE data_sets (
    id integer NOT NULL,
    layer_type character varying NOT NULL,
    file_path character varying,
    import_table_name character varying,
    data_table_name character varying NOT NULL,
    encoding character varying,
    start date NOT NULL,
    stop date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: data_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE data_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: data_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE data_sets_id_seq OWNED BY data_sets.id;


--
-- Name: indian_lands; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW indian_lands AS
 SELECT d.gid,
    d.objectid,
    d.id,
    d.indian,
    d.state,
    d.census,
    d.gnis,
    d.name,
    d.type,
    d.class,
    d.recognitio,
    d.land_area,
    d.water_area,
    d.shape_leng,
    d.shape_area,
    d.geom,
    d.effective,
    d.expires
   FROM data.indian_lands d
  WITH NO DATA;


--
-- Name: qct; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW qct AS
 SELECT d.gid,
    d.tract_fips,
    d.county,
    d.state,
    d.omb_delineation,
    d.prior_status,
    d.current_status,
    d.status_change,
    d.redesignated,
    d.expires,
    d.geom,
    d.effective
   FROM data.qct_2017_01_01 d
  WHERE ((d.current_status)::text <> 'Not Qualified'::text)
  WITH NO DATA;


--
-- Name: qct_brac; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW qct_brac AS
 SELECT d.gid,
    d.brac_id,
    d.brac_sba_name,
    d.tract_fips,
    d.effective,
    d.expires,
    d.publish_date,
    d.qct_data_table,
    d.brac,
    d.geom,
    d.raw_geom
   FROM data.qct_brac d
  WHERE (d.brac IS TRUE)
  WITH NO DATA;


--
-- Name: qct_e; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW qct_e AS
 SELECT d.gid,
    d.tract_fips,
    d.county,
    d.state,
    d.omb_delineation,
    d.prior_status,
    d.current_status,
    d.status_change,
    d.redesignated,
    d.expires,
    d.geom,
    d.effective
   FROM data.qct_2017_01_01 d
  WHERE ((d.redesignated = false) AND ((d.current_status)::text = 'Qualified'::text))
  WITH NO DATA;


--
-- Name: qct_qda; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW qct_qda AS
 SELECT d.gid,
    d.county_fips,
    d.tract_fips,
    d.qda_id,
    d.qda_publish,
    d.qda_declaration,
    d.qct_max_expires,
    d.qct_current_status,
    d.qda_designation,
    d.expires,
    d.geom,
    qda.disaster_state,
    qda.disaster_type,
    qda.fema_code,
    qda.incident_description,
    qda.incidence_period,
    qda.amendment
   FROM data.qct_qda d,
    ( SELECT qct_qda.tract_fips,
            min(qct_qda.qda_publish) AS first_publish
           FROM data.qct_qda
          WHERE ((qct_qda.qda_designation IS NOT NULL) AND ((qct_qda.qct_current_status)::text = 'not-qualified'::text))
          GROUP BY qct_qda.tract_fips) first_report,
    data.qda qda
  WHERE (((d.tract_fips)::text = (first_report.tract_fips)::text) AND (d.qda_publish = first_report.first_publish) AND (d.qda_id = qda.gid))
  WITH NO DATA;


--
-- Name: qct_r; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW qct_r AS
 SELECT d.gid,
    d.tract_fips,
    d.county,
    d.state,
    d.omb_delineation,
    d.prior_status,
    d.current_status,
    d.status_change,
    d.redesignated,
    d.expires,
    d.geom,
    d.effective
   FROM data.qct_2017_01_01 d
  WHERE (d.redesignated = true)
  WITH NO DATA;


--
-- Name: qnmc; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW qnmc AS
 SELECT d.gid,
    d.county_fips,
    d.county,
    d.state,
    d.march_2017_status_current,
    d.median_household_income_ratio_2016,
    d.state_unemployment_ratio_2015,
    d.us_unemployment_ratio_2015,
    d.omb_delineation,
    d.q_inc_2017,
    d.initial_analysis,
    d.q_dda_2017,
    d.july_2016_status_previous,
    d.income,
    d.unemployment,
    d.dda,
    d.redesignated,
    d.expires,
    d.geom,
    d.effective,
    d.qda
   FROM data.qnmc_2017_03_01 d
  WHERE ((d.redesignated = true) OR (d.income = true) OR (d.dda = true) OR (d.unemployment = true))
  WITH NO DATA;


--
-- Name: qnmc_brac; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW qnmc_brac AS
 SELECT d.gid,
    d.brac_id,
    d.brac_sba_name,
    d.county_fips,
    d.effective,
    d.expires,
    d.publish_date,
    d.qnmc_data_table,
    d.brac,
    d.geom,
    d.raw_geom
   FROM data.qnmc_brac d
  WHERE (d.brac IS TRUE)
  WITH NO DATA;


--
-- Name: qnmc_e; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW qnmc_e AS
 SELECT d.gid,
    d.county_fips,
    d.county,
    d.state,
    d.march_2017_status_current,
    d.median_household_income_ratio_2016,
    d.state_unemployment_ratio_2015,
    d.us_unemployment_ratio_2015,
    d.omb_delineation,
    d.q_inc_2017,
    d.initial_analysis,
    d.q_dda_2017,
    d.july_2016_status_previous,
    d.income,
    d.unemployment,
    d.dda,
    d.redesignated,
    d.expires,
    d.geom,
    d.effective,
    d.qda
   FROM data.qnmc_2017_03_01 d
  WHERE ((d.redesignated = false) AND ((d.income = true) OR (d.dda = true) OR (d.unemployment = true)))
  WITH NO DATA;


--
-- Name: qnmc_qda; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW qnmc_qda AS
 SELECT d.gid,
    d.county_fips,
    d.qda_id,
    d.qda_publish,
    d.qda_declaration,
    d.qnmc_max_expires,
    d.qnmc_current_status,
    d.qnmc_current_omb,
    d.qda_designation,
    d.expires,
    d.geom,
    qda.disaster_state,
    qda.disaster_type,
    qda.fema_code,
    qda.incident_description,
    qda.incidence_period,
    qda.amendment
   FROM data.qnmc_qda d,
    ( SELECT qnmc_qda.county_fips,
            min(qnmc_qda.qda_publish) AS first_publish
           FROM data.qnmc_qda
          WHERE ((qnmc_qda.qda_designation IS NOT NULL) AND ((qnmc_qda.qnmc_current_status)::text = 'not-qualified'::text))
          GROUP BY qnmc_qda.county_fips) first_report,
    data.qda qda
  WHERE (((d.county_fips)::text = (first_report.county_fips)::text) AND (d.qda_publish = first_report.first_publish) AND (d.qda_id = qda.gid))
  WITH NO DATA;


--
-- Name: qnmc_r; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW qnmc_r AS
 SELECT d.gid,
    d.county_fips,
    d.county,
    d.state,
    d.march_2017_status_current,
    d.median_household_income_ratio_2016,
    d.state_unemployment_ratio_2015,
    d.us_unemployment_ratio_2015,
    d.omb_delineation,
    d.q_inc_2017,
    d.initial_analysis,
    d.q_dda_2017,
    d.july_2016_status_previous,
    d.income,
    d.unemployment,
    d.dda,
    d.redesignated,
    d.expires,
    d.geom,
    d.effective,
    d.qda
   FROM data.qnmc_2017_03_01 d
  WHERE (d.redesignated = true)
  WITH NO DATA;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


SET search_path = data, pg_catalog;

--
-- Name: gid; Type: DEFAULT; Schema: data; Owner: -
--

ALTER TABLE ONLY brac ALTER COLUMN gid SET DEFAULT nextval('brac_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: data; Owner: -
--

ALTER TABLE ONLY county_changes ALTER COLUMN gid SET DEFAULT nextval('county_changes_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: data; Owner: -
--

ALTER TABLE ONLY master_county_names ALTER COLUMN gid SET DEFAULT nextval('master_county_names_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: data; Owner: -
--

ALTER TABLE ONLY qct_brac ALTER COLUMN gid SET DEFAULT nextval('qct_brac_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: data; Owner: -
--

ALTER TABLE ONLY qct_qda ALTER COLUMN gid SET DEFAULT nextval('qct_qda_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: data; Owner: -
--

ALTER TABLE ONLY qda ALTER COLUMN gid SET DEFAULT nextval('qda_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: data; Owner: -
--

ALTER TABLE ONLY qnmc_brac ALTER COLUMN gid SET DEFAULT nextval('qnmc_brac_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: data; Owner: -
--

ALTER TABLE ONLY qnmc_qda ALTER COLUMN gid SET DEFAULT nextval('qnmc_qda_gid_seq'::regclass);


SET search_path = import, pg_catalog;

--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY brac_2016_10_01 ALTER COLUMN gid SET DEFAULT nextval('brac_2016_10_01_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY indianlands_2014 ALTER COLUMN gid SET DEFAULT nextval('indianlands_2014_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY master_counties ALTER COLUMN gid SET DEFAULT nextval('master_counties_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY master_tracts ALTER COLUMN gid SET DEFAULT nextval('master_tracts_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY qct_2012_10_01 ALTER COLUMN gid SET DEFAULT nextval('qct_2012_10_01_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY qct_2015_01_01 ALTER COLUMN gid SET DEFAULT nextval('qct_2015_01_01_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY qct_2016_03_01 ALTER COLUMN gid SET DEFAULT nextval('qct_2016_03_01_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY qct_2017_01_01 ALTER COLUMN gid SET DEFAULT nextval('qct_2017_01_01_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY qda_2016_11_01 ALTER COLUMN gid SET DEFAULT nextval('qda_2016_11_01_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY qda_2017_03_01 ALTER COLUMN gid SET DEFAULT nextval('qda_2017_03_01_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY qda_2017_04_01 ALTER COLUMN gid SET DEFAULT nextval('qda_2017_04_01_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY qda_2017_05_01 ALTER COLUMN gid SET DEFAULT nextval('qda_2017_05_01_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY qnmc_2013_01_01 ALTER COLUMN gid SET DEFAULT nextval('qnmc_2013_01_01_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY qnmc_2013_05_01 ALTER COLUMN gid SET DEFAULT nextval('qnmc_2013_05_01_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY qnmc_2014_01_01 ALTER COLUMN gid SET DEFAULT nextval('qnmc_2014_01_01_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY qnmc_2014_05_01 ALTER COLUMN gid SET DEFAULT nextval('qnmc_2014_05_01_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY qnmc_2015_01_01 ALTER COLUMN gid SET DEFAULT nextval('qnmc_2015_01_01_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY qnmc_2015_07_01 ALTER COLUMN gid SET DEFAULT nextval('qnmc_2015_07_01_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY qnmc_2016_03_01 ALTER COLUMN gid SET DEFAULT nextval('qnmc_2016_03_01_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY qnmc_2016_07_01 ALTER COLUMN gid SET DEFAULT nextval('qnmc_2016_07_01_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY qnmc_2017_03_01 ALTER COLUMN gid SET DEFAULT nextval('qnmc_2017_03_01_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY raw_counties ALTER COLUMN gid SET DEFAULT nextval('raw_counties_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY raw_tracts ALTER COLUMN gid SET DEFAULT nextval('raw_tracts_gid_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY data_sets ALTER COLUMN id SET DEFAULT nextval('data_sets_id_seq'::regclass);


SET search_path = data, pg_catalog;

--
-- Name: brac_pkey; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY brac
    ADD CONSTRAINT brac_pkey PRIMARY KEY (gid);


--
-- Name: county_changes_pkey; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY county_changes
    ADD CONSTRAINT county_changes_pkey PRIMARY KEY (gid);


--
-- Name: master_county_names_pkey; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY master_county_names
    ADD CONSTRAINT master_county_names_pkey PRIMARY KEY (gid);


--
-- Name: qct_brac_pkey; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY qct_brac
    ADD CONSTRAINT qct_brac_pkey PRIMARY KEY (gid);


--
-- Name: qct_qda_pkey; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY qct_qda
    ADD CONSTRAINT qct_qda_pkey PRIMARY KEY (gid);


--
-- Name: qda_pkey; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY qda
    ADD CONSTRAINT qda_pkey PRIMARY KEY (gid);


--
-- Name: qnmc_brac_pkey; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY qnmc_brac
    ADD CONSTRAINT qnmc_brac_pkey PRIMARY KEY (gid);


--
-- Name: qnmc_qda_pkey; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY qnmc_qda
    ADD CONSTRAINT qnmc_qda_pkey PRIMARY KEY (gid);


SET search_path = import, pg_catalog;

--
-- Name: brac_2016_10_01_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY brac_2016_10_01
    ADD CONSTRAINT brac_2016_10_01_pkey PRIMARY KEY (gid);


--
-- Name: indianlands_2014_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY indianlands_2014
    ADD CONSTRAINT indianlands_2014_pkey PRIMARY KEY (gid);


--
-- Name: master_counties_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY master_counties
    ADD CONSTRAINT master_counties_pkey PRIMARY KEY (gid);


--
-- Name: master_tracts_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY master_tracts
    ADD CONSTRAINT master_tracts_pkey PRIMARY KEY (gid);


--
-- Name: qct_2012_10_01_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY qct_2012_10_01
    ADD CONSTRAINT qct_2012_10_01_pkey PRIMARY KEY (gid);


--
-- Name: qct_2015_01_01_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY qct_2015_01_01
    ADD CONSTRAINT qct_2015_01_01_pkey PRIMARY KEY (gid);


--
-- Name: qct_2016_03_01_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY qct_2016_03_01
    ADD CONSTRAINT qct_2016_03_01_pkey PRIMARY KEY (gid);


--
-- Name: qct_2017_01_01_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY qct_2017_01_01
    ADD CONSTRAINT qct_2017_01_01_pkey PRIMARY KEY (gid);


--
-- Name: qda_2016_11_01_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY qda_2016_11_01
    ADD CONSTRAINT qda_2016_11_01_pkey PRIMARY KEY (gid);


--
-- Name: qda_2017_03_01_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY qda_2017_03_01
    ADD CONSTRAINT qda_2017_03_01_pkey PRIMARY KEY (gid);


--
-- Name: qda_2017_04_01_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY qda_2017_04_01
    ADD CONSTRAINT qda_2017_04_01_pkey PRIMARY KEY (gid);


--
-- Name: qda_2017_05_01_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY qda_2017_05_01
    ADD CONSTRAINT qda_2017_05_01_pkey PRIMARY KEY (gid);


--
-- Name: qnmc_2013_01_01_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY qnmc_2013_01_01
    ADD CONSTRAINT qnmc_2013_01_01_pkey PRIMARY KEY (gid);


--
-- Name: qnmc_2013_05_01_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY qnmc_2013_05_01
    ADD CONSTRAINT qnmc_2013_05_01_pkey PRIMARY KEY (gid);


--
-- Name: qnmc_2014_01_01_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY qnmc_2014_01_01
    ADD CONSTRAINT qnmc_2014_01_01_pkey PRIMARY KEY (gid);


--
-- Name: qnmc_2014_05_01_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY qnmc_2014_05_01
    ADD CONSTRAINT qnmc_2014_05_01_pkey PRIMARY KEY (gid);


--
-- Name: qnmc_2015_01_01_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY qnmc_2015_01_01
    ADD CONSTRAINT qnmc_2015_01_01_pkey PRIMARY KEY (gid);


--
-- Name: qnmc_2015_07_01_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY qnmc_2015_07_01
    ADD CONSTRAINT qnmc_2015_07_01_pkey PRIMARY KEY (gid);


--
-- Name: qnmc_2016_03_01_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY qnmc_2016_03_01
    ADD CONSTRAINT qnmc_2016_03_01_pkey PRIMARY KEY (gid);


--
-- Name: qnmc_2016_07_01_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY qnmc_2016_07_01
    ADD CONSTRAINT qnmc_2016_07_01_pkey PRIMARY KEY (gid);


--
-- Name: qnmc_2017_03_01_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY qnmc_2017_03_01
    ADD CONSTRAINT qnmc_2017_03_01_pkey PRIMARY KEY (gid);


--
-- Name: raw_counties_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY raw_counties
    ADD CONSTRAINT raw_counties_pkey PRIMARY KEY (gid);


--
-- Name: raw_tracts_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY raw_tracts
    ADD CONSTRAINT raw_tracts_pkey PRIMARY KEY (gid);


SET search_path = public, pg_catalog;

--
-- Name: ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: data_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY data_sets
    ADD CONSTRAINT data_sets_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


SET search_path = data, pg_catalog;

--
-- Name: qct_2012_10_01_gix; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX qct_2012_10_01_gix ON qct_2012_10_01 USING gist (geom);


--
-- Name: qct_2015_01_01_gix; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX qct_2015_01_01_gix ON qct_2015_01_01 USING gist (geom);


--
-- Name: qct_2016_03_01_gix; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX qct_2016_03_01_gix ON qct_2016_03_01 USING gist (geom);


--
-- Name: qct_2017_01_01_gix; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX qct_2017_01_01_gix ON qct_2017_01_01 USING gist (geom);


--
-- Name: qnmc_2013_01_01_gix; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX qnmc_2013_01_01_gix ON qnmc_2013_01_01 USING gist (geom);


--
-- Name: qnmc_2013_05_01_gix; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX qnmc_2013_05_01_gix ON qnmc_2013_05_01 USING gist (geom);


--
-- Name: qnmc_2014_01_01_gix; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX qnmc_2014_01_01_gix ON qnmc_2014_01_01 USING gist (geom);


--
-- Name: qnmc_2014_05_01_gix; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX qnmc_2014_05_01_gix ON qnmc_2014_05_01 USING gist (geom);


--
-- Name: qnmc_2015_01_01_gix; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX qnmc_2015_01_01_gix ON qnmc_2015_01_01 USING gist (geom);


--
-- Name: qnmc_2015_07_01_gix; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX qnmc_2015_07_01_gix ON qnmc_2015_07_01 USING gist (geom);


--
-- Name: qnmc_2016_03_01_gix; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX qnmc_2016_03_01_gix ON qnmc_2016_03_01 USING gist (geom);


--
-- Name: qnmc_2016_07_01_gix; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX qnmc_2016_07_01_gix ON qnmc_2016_07_01 USING gist (geom);


--
-- Name: qnmc_2017_03_01_gix; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX qnmc_2017_03_01_gix ON qnmc_2017_03_01 USING gist (geom);


SET search_path = import, pg_catalog;

--
-- Name: brac_2016_10_01_geom_idx; Type: INDEX; Schema: import; Owner: -
--

CREATE INDEX brac_2016_10_01_geom_idx ON brac_2016_10_01 USING gist (geom);


--
-- Name: indianlands_2014_geom_idx; Type: INDEX; Schema: import; Owner: -
--

CREATE INDEX indianlands_2014_geom_idx ON indianlands_2014 USING gist (geom);


SET search_path = public, pg_catalog;

--
-- Name: brac_gix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX brac_gix ON brac USING gist (geom);


--
-- Name: index_data_sets_on_layer_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_data_sets_on_layer_type ON data_sets USING btree (layer_type);


--
-- Name: indian_lands_gix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indian_lands_gix ON indian_lands USING gist (geom);


--
-- Name: qct_brac_gix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qct_brac_gix ON qct_brac USING gist (geom);


--
-- Name: qct_e_gix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qct_e_gix ON qct_e USING gist (geom);


--
-- Name: qct_gix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qct_gix ON qct USING gist (geom);


--
-- Name: qct_qda_gix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qct_qda_gix ON qct_qda USING gist (geom);


--
-- Name: qct_r_gix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qct_r_gix ON qct_r USING gist (geom);


--
-- Name: qnmc_brac_gix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qnmc_brac_gix ON qnmc_brac USING gist (geom);


--
-- Name: qnmc_e_gix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qnmc_e_gix ON qnmc_e USING gist (geom);


--
-- Name: qnmc_gix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qnmc_gix ON qnmc USING gist (geom);


--
-- Name: qnmc_qda_gix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qnmc_qda_gix ON qnmc_qda USING gist (geom);


--
-- Name: qnmc_r_gix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qnmc_r_gix ON qnmc_r USING gist (geom);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES
('20161003200320'),
('20170103191227'),
('20170203210522');


