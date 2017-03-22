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
-- Name: brac; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE brac (
    gid integer,
    sba_name character varying(36),
    county character varying(36),
    st_name character varying(25),
    fac_type character varying(25),
    closure character varying(15),
    geom public.geometry(MultiPolygon,4326),
    effective date DEFAULT ('now'::text)::date NOT NULL,
    expires date
);


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
    effective date DEFAULT ('now'::text)::date NOT NULL,
    expires date,
    redesignated boolean DEFAULT false NOT NULL,
    brac_id integer
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
    effective date DEFAULT ('now'::text)::date NOT NULL,
    expires date,
    income boolean DEFAULT false NOT NULL,
    unemployment boolean DEFAULT false NOT NULL,
    redesignated boolean DEFAULT false NOT NULL,
    dda boolean DEFAULT false NOT NULL,
    brac_id integer
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
-- Name: etl_hz; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE etl_hz (
    gid integer NOT NULL,
    statefp character varying(2),
    countyfp character varying(3),
    ansicode character varying(8),
    hydroid character varying(22),
    fullname character varying(100),
    mtfcc character varying(5),
    aland double precision,
    awater double precision,
    intptlat character varying(11),
    intptlon character varying(12),
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: etl_hz_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE etl_hz_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: etl_hz_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE etl_hz_gid_seq OWNED BY etl_hz.gid;


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
    d.effective,
    d.expires
   FROM data.brac d;


--
-- Name: data_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE data_sets (
    id integer NOT NULL,
    layer_type character varying NOT NULL,
    shapefile character varying,
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
    d.effective,
    d.expires
   FROM data.indian_lands d;


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
    d.effective,
    d.expires,
    d.redesignated,
    d.brac_id
   FROM data.qct_2016_01_01 d;


--
-- Name: qct_brac; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW qct_brac AS
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
    d.effective,
    d.expires,
    d.redesignated,
    d.brac_id
   FROM data.qct_2016_01_01 d
  WHERE (d.brac_id IS NOT NULL);


--
-- Name: qct_e; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW qct_e AS
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
    d.effective,
    d.expires,
    d.redesignated,
    d.brac_id
   FROM data.qct_2016_01_01 d
  WHERE ((d.redesignated = false) AND (d.brac_id IS NULL));


--
-- Name: qct_r; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW qct_r AS
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
    d.effective,
    d.expires,
    d.redesignated,
    d.brac_id
   FROM data.qct_2016_01_01 d
  WHERE (d.redesignated = true);


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
    d.effective,
    d.expires,
    d.income,
    d.unemployment,
    d.redesignated,
    d.dda,
    d.brac_id
   FROM data.qnmc_2016_01_01 d;


--
-- Name: qnmc_brac; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW qnmc_brac AS
 SELECT d.gid,
    d.county,
    d.name,
    d.f2016_sba_,
    d.f2016_sba1,
    d.brac_2016,
    d.geom,
    d.effective,
    d.expires,
    d.income,
    d.unemployment,
    d.redesignated,
    d.dda,
    d.brac_id
   FROM data.qnmc_2016_01_01 d
  WHERE (d.brac_id IS NOT NULL);


--
-- Name: qnmc_e; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW qnmc_e AS
 SELECT d.gid,
    d.county,
    d.name,
    d.f2016_sba_,
    d.f2016_sba1,
    d.brac_2016,
    d.geom,
    d.effective,
    d.expires,
    d.income,
    d.unemployment,
    d.redesignated,
    d.dda,
    d.brac_id
   FROM data.qnmc_2016_01_01 d
  WHERE ((d.redesignated = false) AND (d.brac_id IS NULL));


--
-- Name: qnmc_r; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW qnmc_r AS
 SELECT d.gid,
    d.county,
    d.name,
    d.f2016_sba_,
    d.f2016_sba1,
    d.brac_2016,
    d.geom,
    d.effective,
    d.expires,
    d.income,
    d.unemployment,
    d.redesignated,
    d.dda,
    d.brac_id
   FROM data.qnmc_2016_01_01 d
  WHERE (d.redesignated = true);


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

ALTER TABLE ONLY etl_hz ALTER COLUMN gid SET DEFAULT nextval('etl_hz_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY hubzone_qualified_tracts ALTER COLUMN gid SET DEFAULT nextval('hubzone_qualified_tracts_gid_seq'::regclass);


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

ALTER TABLE ONLY qualified_nonmetro_counties ALTER COLUMN gid SET DEFAULT nextval('qualified_nonmetro_counties_gid_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY data_sets ALTER COLUMN id SET DEFAULT nextval('data_sets_id_seq'::regclass);


SET search_path = import, pg_catalog;

--
-- Name: brac_base_boundaries_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY brac_base_boundaries
    ADD CONSTRAINT brac_base_boundaries_pkey PRIMARY KEY (gid);


--
-- Name: etl_hz_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY etl_hz
    ADD CONSTRAINT etl_hz_pkey PRIMARY KEY (gid);


--
-- Name: hubzone_qualified_tracts_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY hubzone_qualified_tracts
    ADD CONSTRAINT hubzone_qualified_tracts_pkey PRIMARY KEY (gid);


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
-- Name: data_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY data_sets
    ADD CONSTRAINT data_sets_pkey PRIMARY KEY (id);


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
-- Name: etl_hz_geom_idx; Type: INDEX; Schema: import; Owner: -
--

CREATE INDEX etl_hz_geom_idx ON etl_hz USING gist (geom);


--
-- Name: hubzone_qualified_tracts_geom_idx; Type: INDEX; Schema: import; Owner: -
--

CREATE INDEX hubzone_qualified_tracts_geom_idx ON hubzone_qualified_tracts USING gist (geom);


--
-- Name: qualified_nonmetro_counties_geom_idx; Type: INDEX; Schema: import; Owner: -
--

CREATE INDEX qualified_nonmetro_counties_geom_idx ON qualified_nonmetro_counties USING gist (geom);


SET search_path = public, pg_catalog;

--
-- Name: index_data_sets_on_layer_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_data_sets_on_layer_type ON data_sets USING btree (layer_type);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES
('20161003200320'),
('20170103191227');


