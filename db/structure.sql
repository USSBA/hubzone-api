SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
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


--
-- Name: fx_insert_acs_emp_all(character varying, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fx_insert_acs_emp_all(obj_tract character varying, est_total numeric, est_total_margin_err numeric, est_labor_rate numeric, est_labor_rate_margin_err numeric, est_emp_pop_ratio numeric, est_emp_pop_ratio_margin_err numeric, est_unemp_rate numeric, est_unemp_rate_margin_err numeric, state_fip character varying, county_fip character varying, tract_code character varying, acs_year character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
        INSERT INTO public.acs_emp_all(obj_tract,
								est_total,
								est_total_margin_err,
								est_labor_rate,
								est_labor_rate_margin_err,
								est_emp_pop_ratio,
								est_emp_pop_ratio_margin_err,
								est_unemp_rate,
								est_unemp_rate_margin_err,
								state_fip,
								county_fip,
								tract_code,
								acs_year)
        VALUES(obj_tract,
				est_total,
				est_total_margin_err,
				est_labor_rate,
				est_labor_rate_margin_err,
				est_emp_pop_ratio,
				est_emp_pop_ratio_margin_err,
				est_unemp_rate,
				est_unemp_rate_margin_err,
				state_fip,
				county_fip,
				tract_code,
				acs_year);
      END;
$$;


--
-- Name: fx_insert_census_pop(numeric, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fx_insert_census_pop(population numeric, state_fip character varying, county_fip character varying, census_year character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO public.census_population(
		population,
		state_fip,
		county_fip,
		census_year
	)
	VALUES(population,
		  state_fip,
		  county_fip
		  , census_year);
END;
$$;


--
-- Name: fx_insert_econ_char_all(character varying, character varying, numeric, numeric, numeric, numeric, numeric, numeric, numeric, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fx_insert_econ_char_all(geo_id character varying, name_obj character varying, total_pop numeric, total_labor_force numeric, total_civilian_labor_force numeric, total_civilian_labor_force_employ numeric, total_civilian_labor_force_unemploy numeric, total_armed_forces_labor_force numeric, total_not_in_labor numeric, state_fip character varying, county_fip character varying, tract_code character varying, acs_year character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
        INSERT INTO public.acs_econ_char_all(
    	geo_id,
	name_obj,
	total_pop,
	total_labor_force,
	total_civilian_labor_force,
	total_civilian_labor_force_employ,
	total_civilian_labor_force_unemploy,
	total_armed_forces_labor_force,
	total_not_in_labor,
	state_fip,
	county_fip,
	tract_code,
	acs_year 
			)
        VALUES(
   	 geo_id,
	name_obj,
	total_pop,
	total_labor_force,
	total_civilian_labor_force,
	total_civilian_labor_force_employ,
	total_civilian_labor_force_unemploy,
	total_armed_forces_labor_force,
	total_not_in_labor,
	state_fip,
	county_fip,
	tract_code,
	acs_year );
      END;
	$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: treasury_opportunity_zones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.treasury_opportunity_zones (
    id integer NOT NULL,
    geom public.geometry(MultiPolygon,3857),
    "OBJECTID" bigint,
    "GEOID10" character varying(11),
    "Shape__Area" double precision,
    "Shape__Length" double precision
);


--
-- Name: US Dept of Treasury Opportunity Zones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."US Dept of Treasury Opportunity Zones_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: US Dept of Treasury Opportunity Zones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."US Dept of Treasury Opportunity Zones_id_seq" OWNED BY public.treasury_opportunity_zones.id;


--
-- Name: acs_econ_char_all; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acs_econ_char_all (
    geo_id character varying,
    name_obj character varying,
    total_pop numeric,
    total_labor_force numeric,
    total_civilian_labor_force numeric,
    total_civilian_labor_force_employ numeric,
    total_civilian_labor_force_unemploy numeric,
    total_armed_forces_labor_force numeric,
    total_not_in_labor numeric,
    state_fip character varying,
    county_fip character varying,
    tract_code character varying,
    acs_year character varying
);


--
-- Name: acs_emp_all; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acs_emp_all (
    obj_tract character varying,
    est_total numeric,
    est_total_margin_err numeric,
    est_labor_rate numeric,
    est_labor_rate_margin_err numeric,
    est_emp_pop_ratio numeric,
    est_emp_pop_ratio_margin_err numeric,
    est_unemp_rate numeric,
    est_unemp_rate_margin_err numeric,
    state_fip character varying,
    county_fip character varying,
    tract_code character varying,
    acs_year character varying,
    pop_tract numeric
);


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bls_unemploy_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bls_unemploy_states (
    series_id character varying,
    year character varying,
    period character varying,
    value double precision,
    footnote_codes character varying
);


--
-- Name: census_county; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.census_county (
    ogc_fid integer NOT NULL,
    statefp character varying(2),
    countyfp character varying(3),
    countyns character varying(8),
    geoid character varying(5),
    name character varying(100),
    namelsad character varying(100),
    lsad character varying(2),
    classfp character varying(2),
    mtfcc character varying(5),
    csafp character varying(3),
    cbsafp character varying(5),
    metdivfp character varying(5),
    funcstat character varying(1),
    aland numeric(14,0),
    awater numeric(14,0),
    intptlat character varying(11),
    intptlon character varying(12),
    wkb_geometry public.geometry(Geometry,4326),
    census_year character varying
);


--
-- Name: census_county_ogc_fid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.census_county_ogc_fid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: census_county_ogc_fid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.census_county_ogc_fid_seq OWNED BY public.census_county.ogc_fid;


--
-- Name: census_population; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.census_population (
    population numeric,
    state_fip character varying,
    county_fip character varying,
    census_year character varying
);


--
-- Name: census_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.census_state (
    ogc_fid integer NOT NULL,
    region character varying(2),
    division character varying(2),
    statefp character varying(2),
    statens character varying(8),
    geoid character varying(2),
    stusps character varying(2),
    name character varying(100),
    lsad character varying(2),
    mtfcc character varying(5),
    funcstat character varying(1),
    aland numeric(14,0),
    awater numeric(14,0),
    intptlat character varying(11),
    intptlon character varying(12),
    wkb_geometry public.geometry(Geometry,4326),
    census_year character varying
);


--
-- Name: census_state_ogc_fid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.census_state_ogc_fid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: census_state_ogc_fid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.census_state_ogc_fid_seq OWNED BY public.census_state.ogc_fid;


--
-- Name: census_tract; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.census_tract (
    id integer NOT NULL,
    geom public.geometry(MultiPolygon,4269),
    statefp character varying(2),
    countyfp character varying(3),
    tractce character varying(6),
    geoid character varying(11),
    name character varying(7),
    namelsad character varying(20),
    mtfcc character varying(5),
    funcstat character varying(1),
    aland bigint,
    awater bigint,
    intptlat character varying(11),
    intptlon character varying(12),
    census_year character varying
);


--
-- Name: census_urban_area; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.census_urban_area (
    gid integer,
    uace10 character varying(5),
    geoid10 character varying(5),
    name10 character varying(100),
    namelsad10 character varying(100),
    lsad10 character varying(2),
    mtfcc10 character varying(5),
    uatyp10 character varying(1),
    funcstat10 character varying(1),
    aland10 double precision,
    awater10 double precision,
    intptlat10 character varying(11),
    intptlon10 character varying(12),
    geom public.geometry(MultiPolygon),
    census_year character varying(4)
);


--
-- Name: fips_mapping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fips_mapping (
    state_name character varying,
    stusab character varying,
    fips character varying,
    fip_year character varying,
    gnis character varying,
    is_state boolean,
    is_major boolean
);


--
-- Name: nat_unemploy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nat_unemploy (
    admin_type character varying,
    admin_name character varying,
    unemploy_value numeric,
    unemploy_rate numeric,
    unemploy_year character varying,
    unemploy_month character varying
);


--
-- Name: demo_governors_tract; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.demo_governors_tract AS
 WITH tract_geom AS (
         SELECT ct.id,
            ct.statefp,
            ct.countyfp,
            ct.tractce,
            ct.geom
           FROM public.census_tract ct
          WHERE ((NOT (ct.id IN ( SELECT census_tract.id
                   FROM public.census_tract,
                    public.census_urban_area
                  WHERE (public.st_intersects(census_tract.geom, public.st_setsrid(census_urban_area.geom, 4269)) AND ((census_tract.census_year)::text = '2018'::text) AND ((census_urban_area.census_year)::text = '2018'::text) AND ((census_urban_area.uatyp10)::text = 'U'::text) AND ((census_tract.statefp)::text = '17'::text))))) AND ((ct.census_year)::text = '2018'::text) AND ((ct.statefp)::text = '17'::text))
          ORDER BY ct.tractce
        ), national_unmeploy AS (
         SELECT unnat.unemploy_rate AS nat_unemploy_rate,
            unnat.unemploy_year AS nat_unemploy_year,
            unnat.unemploy_month AS nat_unemploy_month
           FROM public.nat_unemploy unnat
          WHERE ((unnat.admin_name)::text = 'United States of America'::text)
        )
 SELECT trt.id,
    aea.est_total AS total_employ,
    aea.est_unemp_rate AS unemp_rate,
    aea.state_fip,
    aea.county_fip,
    aea.tract_code,
    fm.state_name,
    cnty.name,
    un.unemploy_rate AS state_unemploy_rate,
    nat.nat_unemploy_rate,
    round((aea.est_unemp_rate / un.unemploy_rate), 2) AS tract_state_ratio,
    round((aea.est_unemp_rate / nat.nat_unemploy_rate), 2) AS tract_national_ratio,
    cp.population,
    trt.geom,
        CASE
            WHEN (round((aea.est_unemp_rate / un.unemploy_rate), 2) < round((aea.est_unemp_rate / nat.nat_unemploy_rate), 2)) THEN round((aea.est_unemp_rate / un.unemploy_rate), 2)
            ELSE round((aea.est_unemp_rate / nat.nat_unemploy_rate), 2)
        END AS min_unemploy
   FROM ((((((public.acs_emp_all aea
     JOIN public.fips_mapping fm ON (((aea.state_fip)::text = (fm.fips)::text)))
     JOIN public.nat_unemploy un ON (((un.admin_name)::text = (fm.state_name)::text)))
     JOIN public.census_population cp ON ((((cp.state_fip)::text = (aea.state_fip)::text) AND ((cp.county_fip)::text = (aea.county_fip)::text))))
     JOIN national_unmeploy nat ON ((((nat.nat_unemploy_year)::text = (un.unemploy_year)::text) AND ((nat.nat_unemploy_month)::text = (un.unemploy_month)::text))))
     JOIN public.census_county cnty ON ((((aea.state_fip)::text = (cnty.statefp)::text) AND ((aea.county_fip)::text = (cnty.countyfp)::text))))
     JOIN tract_geom trt ON ((((trt.tractce)::text = (aea.tract_code)::text) AND ((trt.countyfp)::text = (aea.county_fip)::text) AND ((trt.statefp)::text = (aea.state_fip)::text))))
  WHERE (((aea.state_fip)::text = '17'::text) AND ((un.unemploy_year)::text = '2020'::text) AND ((un.unemploy_month)::text = '09'::text) AND (cp.population <= (50000)::numeric) AND ((round((aea.est_unemp_rate / un.unemploy_rate), 2) >= 1.2) OR (round((aea.est_unemp_rate / nat.nat_unemploy_rate), 2) >= 1.2)))
  ORDER BY aea.state_fip, aea.county_fip, aea.tract_code;


--
-- Name: mvw_gov_area; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.mvw_gov_area AS
 WITH tract_geom AS (
         SELECT ct.id,
            ct.statefp,
            ct.countyfp,
            ct.tractce,
            ct.geom
           FROM public.census_tract ct
          WHERE ((NOT (ct.id IN ( SELECT census_tract.id
                   FROM public.census_tract,
                    public.census_urban_area
                  WHERE (public.st_intersects(census_tract.geom, public.st_setsrid(census_urban_area.geom, 4269)) AND ((census_tract.census_year)::text = '2018'::text) AND ((census_urban_area.census_year)::text = '2018'::text) AND ((census_urban_area.uatyp10)::text = 'U'::text))))) AND ((ct.census_year)::text = '2018'::text))
          ORDER BY ct.tractce
        ), national_unmeploy AS (
         SELECT unnat.unemploy_rate AS nat_unemploy_rate,
            unnat.unemploy_year AS nat_unemploy_year,
            unnat.unemploy_month AS nat_unemploy_month
           FROM public.nat_unemploy unnat
          WHERE (((unnat.admin_name)::text = 'USA'::text) AND ((unnat.unemploy_year)::text = '2018'::text))
        )
 SELECT trt.id,
    aea.est_total AS tract_employ_pop,
    aea.est_unemp_rate,
    aea.state_fip,
    aea.county_fip,
    aea.tract_code,
    fm.state_name,
    cnty.name AS county_name,
    un.value AS state_unemploy_rate,
    nat.nat_unemploy_rate,
    round((aea.est_unemp_rate / (un.value)::numeric), 2) AS state_ratio,
    round((aea.est_unemp_rate / nat.nat_unemploy_rate), 2) AS national_ratio,
    trt.geom,
        CASE
            WHEN (round((aea.est_unemp_rate / (un.value)::numeric), 2) < round((aea.est_unemp_rate / nat.nat_unemploy_rate), 2)) THEN round((aea.est_unemp_rate / (un.value)::numeric), 2)
            ELSE round((aea.est_unemp_rate / nat.nat_unemploy_rate), 2)
        END AS min_unemploy,
        CASE
            WHEN (trt.id IS NULL) THEN 'Tract Intersects an URBAN AREA'::text
            WHEN (trt.id IS NOT NULL) THEN 'Tract Does Not Intersect an Urban Area'::text
            ELSE 'no tract id found'::text
        END AS tract_in_ua,
        CASE
            WHEN ((round((aea.est_unemp_rate / (un.value)::numeric), 2) >= 1.2) OR (round((aea.est_unemp_rate / nat.nat_unemploy_rate), 2) >= 1.2)) THEN 'Tract State or National Unemployment Rates is GREATER than or EQUAL to 120%'::text
            WHEN ((round((aea.est_unemp_rate / (un.value)::numeric), 2) < 1.2) OR (round((aea.est_unemp_rate / nat.nat_unemploy_rate), 2) < 1.2)) THEN 'Tract State or National Unemployment Rates is LESS than 120%'::text
            ELSE 'No unemployment rates found'::text
        END AS tract_threshold,
        CASE
            WHEN (((round((aea.est_unemp_rate / (un.value)::numeric), 2) >= 1.2) OR (round((aea.est_unemp_rate / nat.nat_unemploy_rate), 2) >= 1.2)) AND (trt.id IS NOT NULL)) THEN 'QUALIFIES'::text
            ELSE 'NOT QUALIFIES'::text
        END AS qualify,
    '12/01/2020'::text AS approve_date,
    false AS is_selected
   FROM (((((public.acs_emp_all aea
     JOIN public.fips_mapping fm ON (((aea.state_fip)::text = (fm.fips)::text)))
     JOIN public.bls_unemploy_states un ON (("substring"(rtrim((un.series_id)::text), 6, 2) = (fm.fips)::text)))
     JOIN national_unmeploy nat ON ((((nat.nat_unemploy_year)::text = '2018'::text) AND ((nat.nat_unemploy_month)::text = '09'::text))))
     JOIN public.census_county cnty ON ((((aea.state_fip)::text = (cnty.statefp)::text) AND ((aea.county_fip)::text = (cnty.countyfp)::text))))
     LEFT JOIN tract_geom trt ON ((((trt.tractce)::text = (aea.tract_code)::text) AND ((trt.countyfp)::text = (aea.county_fip)::text) AND ((trt.statefp)::text = (aea.state_fip)::text))))
  WHERE (((aea.acs_year)::text = '2018'::text) AND ((cnty.census_year)::text = '2018'::text) AND ((un.year)::text = '2018'::text) AND ((un.period)::text = 'M09'::text) AND ("substring"(rtrim((un.series_id)::text), 19, 2) = '03'::text))
  ORDER BY aea.state_fip, aea.county_fip, aea.tract_code
  WITH NO DATA;


--
-- Name: sba_gov_area; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sba_gov_area (
    id integer NOT NULL,
    state_fip character varying,
    county_fip character varying,
    tract_code character varying,
    date_approve date,
    is_active boolean
);


--
-- Name: mvw_gov_area_map; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.mvw_gov_area_map AS
 SELECT sga.state_fip,
    sga.county_fip,
    sga.tract_code,
    sga.date_approve,
    ct.geom
   FROM (public.sba_gov_area sga
     JOIN public.census_tract ct ON ((((sga.state_fip)::text = (ct.statefp)::text) AND ((sga.county_fip)::text = (ct.countyfp)::text) AND ((sga.tract_code)::text = (ct.tractce)::text))))
  WHERE ((ct.census_year)::text = '2018'::text)
  WITH NO DATA;


--
-- Name: mvw_governors_tract_illinois; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.mvw_governors_tract_illinois AS
 WITH tract_geom AS (
         SELECT ct.id,
            ct.statefp,
            ct.countyfp,
            ct.tractce,
            ct.geom
           FROM public.census_tract ct
          WHERE ((NOT (ct.id IN ( SELECT census_tract.id
                   FROM public.census_tract,
                    public.census_urban_area
                  WHERE (public.st_intersects(census_tract.geom, public.st_setsrid(census_urban_area.geom, 4269)) AND ((census_tract.census_year)::text = '2018'::text) AND ((census_urban_area.census_year)::text = '2018'::text) AND ((census_urban_area.uatyp10)::text = 'U'::text) AND ((census_tract.statefp)::text = '17'::text))))) AND ((ct.census_year)::text = '2018'::text) AND ((ct.statefp)::text = '17'::text))
          ORDER BY ct.tractce
        ), national_unmeploy AS (
         SELECT unnat.unemploy_rate AS nat_unemploy_rate,
            unnat.unemploy_year AS nat_unemploy_year,
            unnat.unemploy_month AS nat_unemploy_month
           FROM public.nat_unemploy unnat
          WHERE (((unnat.admin_name)::text = 'USA'::text) AND ((unnat.unemploy_year)::text = '2018'::text) AND ((unnat.unemploy_month)::text = '09'::text))
        )
 SELECT trt.id,
    aea.est_total AS total_tract_employ_pop,
    aea.est_unemp_rate AS tract_unemp_rate,
    aea.state_fip,
    aea.county_fip,
    aea.tract_code,
    fm.state_name,
    cnty.name,
    un.value AS state_unemploy_rate,
    nat.nat_unemploy_rate,
    round((aea.est_unemp_rate / (un.value)::numeric), 2) AS tract_state_ratio,
    round((aea.est_unemp_rate / nat.nat_unemploy_rate), 2) AS tract_national_ratio,
    cp.population,
    trt.geom,
        CASE
            WHEN (round((aea.est_unemp_rate / (un.value)::numeric), 2) < round((aea.est_unemp_rate / nat.nat_unemploy_rate), 2)) THEN round((aea.est_unemp_rate / (un.value)::numeric), 2)
            ELSE round((aea.est_unemp_rate / nat.nat_unemploy_rate), 2)
        END AS min_unemploy,
        CASE
            WHEN (trt.id IS NULL) THEN 'Tract Intersects an URBAN AREA'::text
            WHEN (trt.id IS NOT NULL) THEN 'Tract Does Not Intersect an Urban Area'::text
            ELSE 'no tract id found'::text
        END AS is_trt_in_ua,
        CASE
            WHEN (cp.population > (50000)::numeric) THEN 'The County of Tract has population GREATER than 50,000'::text
            WHEN (cp.population <= (50000)::numeric) THEN 'The County of Tract has population LESS than or EQUAL to 50,000'::text
            ELSE 'No population found'::text
        END AS is_cnty_pop_50k,
        CASE
            WHEN ((round((aea.est_unemp_rate / (un.value)::numeric), 2) >= 1.2) OR (round((aea.est_unemp_rate / nat.nat_unemploy_rate), 2) >= 1.2)) THEN 'Tract State or National Unemployment Rates is GREATER than or EQUAL to 120%'::text
            WHEN ((round((aea.est_unemp_rate / (un.value)::numeric), 2) < 1.2) OR (round((aea.est_unemp_rate / nat.nat_unemploy_rate), 2) < 1.2)) THEN 'Tract State or National Unemployment Rates is LESS than 120%'::text
            ELSE 'No unemployment rates found'::text
        END AS is_unemp_rate_120pct,
        CASE
            WHEN (((round((aea.est_unemp_rate / (un.value)::numeric), 2) >= 1.2) OR (round((aea.est_unemp_rate / nat.nat_unemploy_rate), 2) >= 1.2)) AND (cp.population <= (50000)::numeric) AND (trt.id IS NOT NULL)) THEN 'QUALIFIES'::text
            ELSE 'NOT QUALIFIES'::text
        END AS is_qualify
   FROM ((((((public.acs_emp_all aea
     JOIN public.fips_mapping fm ON (((aea.state_fip)::text = (fm.fips)::text)))
     JOIN public.bls_unemploy_states un ON (("substring"(rtrim((un.series_id)::text), 6, 2) = (fm.fips)::text)))
     JOIN public.census_population cp ON ((((cp.state_fip)::text = (aea.state_fip)::text) AND ((cp.county_fip)::text = (aea.county_fip)::text))))
     JOIN national_unmeploy nat ON ((((nat.nat_unemploy_year)::text = '2018'::text) AND ((nat.nat_unemploy_month)::text = '09'::text))))
     JOIN public.census_county cnty ON ((((aea.state_fip)::text = (cnty.statefp)::text) AND ((aea.county_fip)::text = (cnty.countyfp)::text))))
     LEFT JOIN tract_geom trt ON ((((trt.tractce)::text = (aea.tract_code)::text) AND ((trt.countyfp)::text = (aea.county_fip)::text) AND ((trt.statefp)::text = (aea.state_fip)::text))))
  WHERE (((aea.state_fip)::text = '17'::text) AND ((aea.acs_year)::text = '2018'::text) AND ((un.year)::text = '2018'::text) AND ("substring"(rtrim((un.period)::text), 2, 2) = '09'::text) AND ("substring"(rtrim((un.series_id)::text), 19, 2) = '03'::text) AND ((cp.census_year)::text = '2018'::text) AND ((cnty.census_year)::text = '2018'::text))
  ORDER BY aea.state_fip, aea.county_fip, aea.tract_code
  WITH NO DATA;


--
-- Name: mvw_illinois_acs_only; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.mvw_illinois_acs_only AS
 WITH national_employ AS (
         SELECT sum(aec_1.total_pop) AS nat_pop_labor_force,
            sum(aec_1.total_civilian_labor_force_unemploy) AS nat_civilian_unemploy,
            sum(aec_1.total_civilian_labor_force) AS nat_civilian_labor_force,
            sum(aec_1.total_armed_forces_labor_force) AS nat_armed_forces_labor,
            round(((sum(aec_1.total_civilian_labor_force_unemploy) / sum(aec_1.total_civilian_labor_force)) * (100)::numeric), 2) AS nat_unemploy_rate
           FROM (public.acs_econ_char_all aec_1
             JOIN public.fips_mapping fm_1 ON (((aec_1.state_fip)::text = (fm_1.fips)::text)))
          WHERE (((fm_1.fips)::text <> ALL (ARRAY[('60'::character varying)::text, ('66'::character varying)::text, ('69'::character varying)::text, ('78'::character varying)::text, ('74'::character varying)::text, ('72'::character varying)::text])) AND ((aec_1.acs_year)::text = '2019'::text))
        ), state_employ AS (
         SELECT aec_1.state_fip,
            sum(aec_1.total_pop) AS state_pop_labor_force,
            sum(aec_1.total_civilian_labor_force_unemploy) AS state_civilian_unemploy,
            sum(aec_1.total_civilian_labor_force) AS state_civilian_labor_force,
            sum(aec_1.total_armed_forces_labor_force) AS state_armed_forces_labor,
            round(((sum(aec_1.total_civilian_labor_force_unemploy) / sum(aec_1.total_civilian_labor_force)) * (100)::numeric), 2) AS state_unemploy_rate
           FROM (public.acs_econ_char_all aec_1
             JOIN public.fips_mapping fm_1 ON (((aec_1.state_fip)::text = (fm_1.fips)::text)))
          WHERE (((fm_1.fips)::text <> ALL (ARRAY[('60'::character varying)::text, ('66'::character varying)::text, ('69'::character varying)::text, ('78'::character varying)::text, ('74'::character varying)::text, ('72'::character varying)::text])) AND ((aec_1.acs_year)::text = '2019'::text))
          GROUP BY aec_1.state_fip
        ), county_employ AS (
         SELECT aec_1.state_fip,
            aec_1.county_fip,
            sum(aec_1.total_pop) AS county_pop_labor_force,
            sum(aec_1.total_civilian_labor_force_unemploy) AS county_civilian_unemploy,
            sum(aec_1.total_civilian_labor_force) AS county_civilian_labor_force,
            sum(aec_1.total_armed_forces_labor_force) AS county_armed_forces_labor,
            round(((sum(aec_1.total_civilian_labor_force_unemploy) / sum(aec_1.total_civilian_labor_force)) * (100)::numeric), 2) AS county_unemploy_rate
           FROM (public.acs_econ_char_all aec_1
             JOIN public.fips_mapping fm_1 ON (((aec_1.state_fip)::text = (fm_1.fips)::text)))
          WHERE (((fm_1.fips)::text <> ALL (ARRAY[('60'::character varying)::text, ('66'::character varying)::text, ('69'::character varying)::text, ('78'::character varying)::text, ('74'::character varying)::text, ('72'::character varying)::text])) AND ((aec_1.acs_year)::text = '2019'::text))
          GROUP BY aec_1.state_fip, aec_1.county_fip
        ), tract_employ AS (
         SELECT aec_1.state_fip,
            aec_1.county_fip,
            aec_1.tract_code,
            sum(aec_1.total_pop) AS tract_pop_labor_force,
            sum(aec_1.total_civilian_labor_force_unemploy) AS tract_civilian_unemploy,
            sum(aec_1.total_civilian_labor_force) AS tract_civilian_labor_force,
            sum(aec_1.total_armed_forces_labor_force) AS tract_armed_forces_labor,
                CASE
                    WHEN (sum(aec_1.total_civilian_labor_force) > (0)::numeric) THEN round(((sum(aec_1.total_civilian_labor_force_unemploy) / sum(aec_1.total_civilian_labor_force)) * (100)::numeric), 2)
                    ELSE '0'::numeric
                END AS tract_unemploy_rate
           FROM (public.acs_econ_char_all aec_1
             JOIN public.fips_mapping fm_1 ON (((aec_1.state_fip)::text = (fm_1.fips)::text)))
          WHERE (((fm_1.fips)::text <> ALL (ARRAY[('60'::character varying)::text, ('66'::character varying)::text, ('69'::character varying)::text, ('78'::character varying)::text, ('74'::character varying)::text, ('72'::character varying)::text])) AND ((aec_1.acs_year)::text = '2019'::text))
          GROUP BY aec_1.state_fip, aec_1.county_fip, aec_1.tract_code
        ), tract_geom AS (
         SELECT ct_1.id,
            ct_1.statefp,
            ct_1.countyfp,
            ct_1.tractce,
            ct_1.geom
           FROM public.census_tract ct_1
          WHERE ((NOT (ct_1.id IN ( SELECT census_tract.id
                   FROM public.census_tract,
                    public.census_urban_area
                  WHERE (public.st_intersects(census_tract.geom, public.st_setsrid(census_urban_area.geom, 4269)) AND ((census_tract.census_year)::text = '2019'::text) AND ((census_urban_area.census_year)::text = '2019'::text) AND ((census_urban_area.uatyp10)::text = 'U'::text) AND ((census_tract.statefp)::text = '17'::text))))) AND ((ct_1.census_year)::text = '2019'::text) AND ((ct_1.statefp)::text = '17'::text))
          ORDER BY ct_1.tractce
        )
 SELECT aec.state_fip,
    aec.county_fip,
    aec.tract_code,
    fm.state_name,
    ct.name,
    te.tract_pop_labor_force,
    te.tract_civilian_labor_force,
    ne.nat_unemploy_rate,
    se.state_unemploy_rate,
    ce.county_unemploy_rate,
    te.tract_unemploy_rate,
    ct.geom,
    round((te.tract_unemploy_rate / se.state_unemploy_rate), 2) AS tract_state_ratio,
    round((te.tract_unemploy_rate / ne.nat_unemploy_rate), 2) AS tract_national_ratio,
        CASE
            WHEN (round((te.tract_unemploy_rate / se.state_unemploy_rate), 2) < round((te.tract_unemploy_rate / ne.nat_unemploy_rate), 2)) THEN round((te.tract_unemploy_rate / se.state_unemploy_rate), 2)
            ELSE round((te.tract_unemploy_rate / ne.nat_unemploy_rate), 2)
        END AS min_unemploy,
        CASE
            WHEN (trt.id IS NULL) THEN 'Tract Intersects an URBAN AREA'::text
            WHEN (trt.id IS NOT NULL) THEN 'Tract Does Not Intersect an Urban Area'::text
            ELSE 'no tract id found'::text
        END AS tract_in_ua,
        CASE
            WHEN ((round((te.tract_unemploy_rate / se.state_unemploy_rate), 2) >= 1.2) OR (round((te.tract_unemploy_rate / ne.nat_unemploy_rate), 2) >= 1.2)) THEN 'Tract State or National Unemployment Rates is GREATER than or EQUAL to 120%'::text
            WHEN ((round((te.tract_unemploy_rate / se.state_unemploy_rate), 2) < 1.2) OR (round((te.tract_unemploy_rate / ne.nat_unemploy_rate), 2) < 1.2)) THEN 'Tract State or National Unemployment Rates is LESS than 120%'::text
            ELSE 'No unemployment rates found'::text
        END AS tract_threshold,
        CASE
            WHEN (((round((te.tract_unemploy_rate / se.state_unemploy_rate), 2) >= 1.2) OR (round((te.tract_unemploy_rate / ne.nat_unemploy_rate), 2) >= 1.2)) AND (trt.id IS NOT NULL)) THEN 'QUALIFIES'::text
            ELSE 'NOT QUALIFIES'::text
        END AS qualify,
    ''::text AS is_selected
   FROM public.acs_econ_char_all aec,
    public.fips_mapping fm,
    state_employ se,
    county_employ ce,
    tract_employ te,
    national_employ ne,
    public.census_tract ct,
    tract_geom trt
  WHERE (((aec.state_fip)::text = (fm.fips)::text) AND ((aec.state_fip)::text = (se.state_fip)::text) AND ((aec.state_fip)::text = (ce.state_fip)::text) AND ((aec.county_fip)::text = (ce.county_fip)::text) AND ((aec.state_fip)::text = (te.state_fip)::text) AND ((aec.county_fip)::text = (te.county_fip)::text) AND ((aec.tract_code)::text = (te.tract_code)::text) AND ((aec.tract_code)::text = (ct.tractce)::text) AND ((aec.state_fip)::text = (ct.statefp)::text) AND ((aec.county_fip)::text = (ct.countyfp)::text) AND ((fm.fips)::text <> ALL (ARRAY[('60'::character varying)::text, ('66'::character varying)::text, ('69'::character varying)::text, ('78'::character varying)::text, ('74'::character varying)::text, ('72'::character varying)::text])) AND ((aec.acs_year)::text = '2019'::text) AND ((ct.census_year)::text = '2019'::text) AND ((aec.state_fip)::text = '17'::text) AND ((aec.tract_code)::text = (trt.tractce)::text) AND ((aec.county_fip)::text = (trt.countyfp)::text) AND ((aec.state_fip)::text = (trt.statefp)::text))
  ORDER BY aec.state_fip, aec.county_fip, aec.tract_code
  WITH NO DATA;


--
-- Name: sba_gov_area_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sba_gov_area_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sba_gov_area_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sba_gov_area_id_seq OWNED BY public.sba_gov_area.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: svw_get_all_years_acs_emp_all; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.svw_get_all_years_acs_emp_all AS
 SELECT DISTINCT acs_emp_all.acs_year
   FROM public.acs_emp_all
  ORDER BY acs_emp_all.acs_year;


--
-- Name: svw_get_state_fips; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.svw_get_state_fips AS
 SELECT fips_mapping.fips,
    fips_mapping.stusab
   FROM public.fips_mapping
  ORDER BY fips_mapping.state_name;


--
-- Name: tl_2018_51_tract_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tl_2018_51_tract_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tl_2018_51_tract_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tl_2018_51_tract_id_seq OWNED BY public.census_tract.id;


--
-- Name: census_county ogc_fid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_county ALTER COLUMN ogc_fid SET DEFAULT nextval('public.census_county_ogc_fid_seq'::regclass);


--
-- Name: census_state ogc_fid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_state ALTER COLUMN ogc_fid SET DEFAULT nextval('public.census_state_ogc_fid_seq'::regclass);


--
-- Name: census_tract id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_tract ALTER COLUMN id SET DEFAULT nextval('public.tl_2018_51_tract_id_seq'::regclass);


--
-- Name: sba_gov_area id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sba_gov_area ALTER COLUMN id SET DEFAULT nextval('public.sba_gov_area_id_seq'::regclass);


--
-- Name: treasury_opportunity_zones id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treasury_opportunity_zones ALTER COLUMN id SET DEFAULT nextval('public."US Dept of Treasury Opportunity Zones_id_seq"'::regclass);


--
-- Name: treasury_opportunity_zones US Dept of Treasury Opportunity Zones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treasury_opportunity_zones
    ADD CONSTRAINT "US Dept of Treasury Opportunity Zones_pkey" PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: census_county census_county_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_county
    ADD CONSTRAINT census_county_pkey PRIMARY KEY (ogc_fid);


--
-- Name: census_state census_state_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_state
    ADD CONSTRAINT census_state_pkey PRIMARY KEY (ogc_fid);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: census_tract tl_2018_51_tract_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_tract
    ADD CONSTRAINT tl_2018_51_tract_pkey PRIMARY KEY (id);


--
-- Name: census_county_geom_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX census_county_geom_idx ON public.census_county USING gist (wkb_geometry);


--
-- Name: census_county_wkb_geometry_geom_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX census_county_wkb_geometry_geom_idx ON public.census_county USING gist (wkb_geometry);


--
-- Name: census_state_geom_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX census_state_geom_idx ON public.census_state USING gist (wkb_geometry);


--
-- Name: census_state_wkb_geometry_geom_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX census_state_wkb_geometry_geom_idx ON public.census_state USING gist (wkb_geometry);


--
-- Name: census_tracts_geom_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX census_tracts_geom_idx ON public.census_tract USING gist (geom);


--
-- Name: census_urban_area_geom_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX census_urban_area_geom_idx ON public.census_urban_area USING gist (geom);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20161003200320');


