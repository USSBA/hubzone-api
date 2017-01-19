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

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: brac_2016_01_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE brac_2016_01_01 (
    gid integer,
    sba_name character varying(36),
    county character varying(36),
    st_name character varying(25),
    fac_type character varying(25),
    closure character varying(15),
    geom public.geometry(MultiPolygon,4326),
    start date DEFAULT ('now'::text)::date NOT NULL,
    stop date
);


--
-- Name: indian_lands_2014_01_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE indian_lands_2014_01_01 (
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
    start date DEFAULT ('now'::text)::date NOT NULL,
    stop date
);


--
-- Name: qct_2016_01_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qct_2016_01_01 (
    gid integer,
    tract character varying(11),
    state character varying(2),
    city character varying(24),
    county character varying(24),
    qualified_ character varying(4),
    qualified1 character varying(4),
    hubzone_st character varying(32),
    brac_2016 character varying(36),
    geom public.geometry(MultiPolygon,4326),
    start date DEFAULT ('now'::text)::date NOT NULL,
    stop date
);


--
-- Name: qnmc_2016_01_01; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qnmc_2016_01_01 (
    gid integer,
    county character varying(5),
    name character varying(24),
    f2016_sba_ character varying(32),
    f2016_sba1 character varying(32),
    brac_2016 character varying(36),
    geom public.geometry(MultiPolygon,4326),
    start date DEFAULT ('now'::text)::date NOT NULL,
    stop date
);


SET search_path = import, pg_catalog;

--
-- Name: brac_base_boundaries; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE brac_base_boundaries (
    gid integer NOT NULL,
    sba_name character varying(36),
    county character varying(36),
    st_name character varying(25),
    fac_type character varying(25),
    closure character varying(15),
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: brac_base_boundaries_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE brac_base_boundaries_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brac_base_boundaries_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE brac_base_boundaries_gid_seq OWNED BY brac_base_boundaries.gid;


--
-- Name: hubzone_qualified_tracts; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE hubzone_qualified_tracts (
    gid integer NOT NULL,
    tract character varying(11),
    state character varying(2),
    city character varying(24),
    county character varying(24),
    qualified_ character varying(4),
    qualified1 character varying(4),
    hubzone_st character varying(32),
    brac_2016 character varying(36),
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: hubzone_qualified_tracts_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE hubzone_qualified_tracts_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hubzone_qualified_tracts_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE hubzone_qualified_tracts_gid_seq OWNED BY hubzone_qualified_tracts.gid;


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
-- Name: qualified_nonmetro_counties; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE qualified_nonmetro_counties (
    gid integer NOT NULL,
    county character varying(5),
    name character varying(24),
    f2016_sba_ character varying(32),
    f2016_sba1 character varying(32),
    brac_2016 character varying(36),
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: qualified_nonmetro_counties_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE qualified_nonmetro_counties_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qualified_nonmetro_counties_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE qualified_nonmetro_counties_gid_seq OWNED BY qualified_nonmetro_counties.gid;


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
-- Name: brac; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW brac AS
 SELECT d.gid,
    d.sba_name,
    d.county,
    d.st_name,
    d.fac_type,
    d.closure,
    d.geom,
    d.start,
    d.stop
   FROM data.brac_2016_01_01 d;


--
-- Name: indian_lands; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW indian_lands AS
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
    d.start,
    d.stop
   FROM data.indian_lands_2014_01_01 d;


--
-- Name: qct; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW qct AS
 SELECT d.gid,
    d.tract,
    d.state,
    d.city,
    d.county,
    d.qualified_,
    d.qualified1,
    d.hubzone_st,
    d.brac_2016,
    d.geom,
    d.start,
    d.stop
   FROM data.qct_2016_01_01 d;


--
-- Name: qnmc; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW qnmc AS
 SELECT d.gid,
    d.county,
    d.name,
    d.f2016_sba_,
    d.f2016_sba1,
    d.brac_2016,
    d.geom,
    d.start,
    d.stop
   FROM data.qnmc_2016_01_01 d;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


SET search_path = import, pg_catalog;

--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY brac_base_boundaries ALTER COLUMN gid SET DEFAULT nextval('brac_base_boundaries_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY hubzone_qualified_tracts ALTER COLUMN gid SET DEFAULT nextval('hubzone_qualified_tracts_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY indianlands_2014 ALTER COLUMN gid SET DEFAULT nextval('indianlands_2014_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY qualified_nonmetro_counties ALTER COLUMN gid SET DEFAULT nextval('qualified_nonmetro_counties_gid_seq'::regclass);


--
-- Name: brac_base_boundaries_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY brac_base_boundaries
    ADD CONSTRAINT brac_base_boundaries_pkey PRIMARY KEY (gid);


--
-- Name: hubzone_qualified_tracts_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY hubzone_qualified_tracts
    ADD CONSTRAINT hubzone_qualified_tracts_pkey PRIMARY KEY (gid);


--
-- Name: indianlands_2014_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY indianlands_2014
    ADD CONSTRAINT indianlands_2014_pkey PRIMARY KEY (gid);


--
-- Name: qualified_nonmetro_counties_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY qualified_nonmetro_counties
    ADD CONSTRAINT qualified_nonmetro_counties_pkey PRIMARY KEY (gid);


SET search_path = public, pg_catalog;

--
-- Name: ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


SET search_path = import, pg_catalog;

--
-- Name: brac_base_boundaries_geom_idx; Type: INDEX; Schema: import; Owner: -
--

CREATE INDEX brac_base_boundaries_geom_idx ON brac_base_boundaries USING gist (geom);


--
-- Name: hubzone_qualified_tracts_geom_idx; Type: INDEX; Schema: import; Owner: -
--

CREATE INDEX hubzone_qualified_tracts_geom_idx ON hubzone_qualified_tracts USING gist (geom);


--
-- Name: indianlands_2014_geom_idx; Type: INDEX; Schema: import; Owner: -
--

CREATE INDEX indianlands_2014_geom_idx ON indianlands_2014 USING gist (geom);


--
-- Name: qualified_nonmetro_counties_geom_idx; Type: INDEX; Schema: import; Owner: -
--

CREATE INDEX qualified_nonmetro_counties_geom_idx ON qualified_nonmetro_counties USING gist (geom);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20161003200320');


