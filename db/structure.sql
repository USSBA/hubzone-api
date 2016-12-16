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
-- Name: brac_2014; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE brac_2014 (
    gid integer,
    sba_name character varying(36),
    county character varying(36),
    st_name character varying(25),
    fac_type character varying(25),
    closure character varying(15),
    geom public.geometry(MultiPolygon,4326),
    geom_lowres public.geometry(MultiPolygon,4326),
    geom_lowerres public.geometry(MultiPolygon,4326),
    geom_lowestres public.geometry(MultiPolygon,4326),
    start date DEFAULT ('now'::text)::date NOT NULL,
    stop date
);


--
-- Name: il_2014; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE il_2014 (
    il_gid integer,
    il_objectid integer,
    il_id numeric,
    il_indian character varying(7),
    il_state character varying(2),
    il_census character varying(7),
    il_gnis integer,
    il_name character varying(62),
    il_type character varying(37),
    il_class character varying(54),
    il_recognitio character varying(7),
    il_land_area numeric,
    il_water_area numeric,
    il_shape_leng numeric,
    il_shape_area numeric,
    geom public.geometry(MultiPolygon,4326),
    geom_lowres public.geometry(MultiPolygon,4326),
    geom_lowerres public.geometry(MultiPolygon,4326),
    geom_lowestres public.geometry(MultiPolygon,4326),
    start date DEFAULT ('now'::text)::date NOT NULL,
    stop date
);


--
-- Name: qct; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qct (
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
-- Name: qct_union; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qct_union (
    gid integer NOT NULL,
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: qct_union_gid_seq; Type: SEQUENCE; Schema: data; Owner: -
--

CREATE SEQUENCE qct_union_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qct_union_gid_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: -
--

ALTER SEQUENCE qct_union_gid_seq OWNED BY qct_union.gid;


--
-- Name: qnmc; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qnmc (
    gid integer,
    county character varying(5),
    f2016_sba_ character varying(32),
    f2016_sba1 character varying(32),
    brac_2016 character varying(36),
    geom public.geometry(MultiPolygon,4326),
    start date DEFAULT ('now'::text)::date NOT NULL,
    stop date
);


--
-- Name: qnmc_union; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE qnmc_union (
    gid integer NOT NULL,
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: qnmc_union_gid_seq; Type: SEQUENCE; Schema: data; Owner: -
--

CREATE SEQUENCE qnmc_union_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qnmc_union_gid_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: -
--

ALTER SEQUENCE qnmc_union_gid_seq OWNED BY qnmc_union.gid;


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
   FROM data.brac_2014 d;


--
-- Name: brac_lowerres; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW brac_lowerres AS
 SELECT d.gid,
    d.sba_name,
    d.county,
    d.st_name,
    d.fac_type,
    d.closure,
    d.geom,
    d.start,
    d.stop
   FROM data.brac_2014 d;


--
-- Name: brac_lowestres; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW brac_lowestres AS
 SELECT d.gid,
    d.sba_name,
    d.county,
    d.st_name,
    d.fac_type,
    d.closure,
    d.geom,
    d.start,
    d.stop
   FROM data.brac_2014 d;


--
-- Name: brac_lowres; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW brac_lowres AS
 SELECT d.gid,
    d.sba_name,
    d.county,
    d.st_name,
    d.fac_type,
    d.closure,
    d.geom,
    d.start,
    d.stop
   FROM data.brac_2014 d;


--
-- Name: hz_current; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE hz_current (
    gid integer NOT NULL,
    sourceid integer,
    hztype character varying(20),
    start date,
    stop date,
    res character varying(10) DEFAULT 'high'::character varying,
    geom geometry(MultiPolygon,4326)
);


--
-- Name: hz_current_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE hz_current_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hz_current_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE hz_current_gid_seq OWNED BY hz_current.gid;


--
-- Name: hz_current_lowerres; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE hz_current_lowerres (
    gid integer NOT NULL,
    sourceid integer,
    hztype character varying(20),
    res character varying(10) DEFAULT 'lower'::character varying,
    geom geometry(MultiPolygon,4326)
);


--
-- Name: hz_current_lowerres_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE hz_current_lowerres_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hz_current_lowerres_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE hz_current_lowerres_gid_seq OWNED BY hz_current_lowerres.gid;


--
-- Name: hz_current_lowestres; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE hz_current_lowestres (
    gid integer NOT NULL,
    sourceid integer,
    hztype character varying(20),
    res character varying(10) DEFAULT 'lowest'::character varying,
    geom geometry(MultiPolygon,4326)
);


--
-- Name: hz_current_lowestres_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE hz_current_lowestres_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hz_current_lowestres_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE hz_current_lowestres_gid_seq OWNED BY hz_current_lowestres.gid;


--
-- Name: hz_current_lowres; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE hz_current_lowres (
    gid integer NOT NULL,
    sourceid integer,
    hztype character varying(20),
    res character varying(10) DEFAULT 'low'::character varying,
    geom geometry(MultiPolygon,4326)
);


--
-- Name: hz_current_lowres_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE hz_current_lowres_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hz_current_lowres_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE hz_current_lowres_gid_seq OWNED BY hz_current_lowres.gid;


--
-- Name: indian_lands; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW indian_lands AS
 SELECT d.il_gid AS gid,
    d.il_objectid AS objectid,
    d.il_id AS id,
    d.il_indian AS indian,
    d.il_state AS state,
    d.il_census AS census,
    d.il_gnis AS gnis,
    d.il_name AS name,
    d.il_type AS type,
    d.il_class AS class,
    d.il_recognitio AS recognitio,
    d.il_land_area AS land_area,
    d.il_water_area AS water_area,
    d.il_shape_leng AS shape_leng,
    d.il_shape_area AS shape_area,
    d.geom,
    d.start,
    d.stop
   FROM data.il_2014 d;


--
-- Name: indian_lands_lowerres; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW indian_lands_lowerres AS
 SELECT d.il_gid AS gid,
    d.il_objectid AS objectid,
    d.il_id AS id,
    d.il_indian AS indian,
    d.il_state AS state,
    d.il_census AS census,
    d.il_gnis AS gnis,
    d.il_name AS name,
    d.il_type AS type,
    d.il_class AS class,
    d.il_recognitio AS recognitio,
    d.il_land_area AS land_area,
    d.il_water_area AS water_area,
    d.il_shape_leng AS shape_leng,
    d.il_shape_area AS shape_area,
    d.geom_lowerres AS geom,
    d.start,
    d.stop
   FROM data.il_2014 d;


--
-- Name: indian_lands_lowestres; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW indian_lands_lowestres AS
 SELECT d.il_gid AS gid,
    d.il_objectid AS objectid,
    d.il_id AS id,
    d.il_indian AS indian,
    d.il_state AS state,
    d.il_census AS census,
    d.il_gnis AS gnis,
    d.il_name AS name,
    d.il_type AS type,
    d.il_class AS class,
    d.il_recognitio AS recognitio,
    d.il_land_area AS land_area,
    d.il_water_area AS water_area,
    d.il_shape_leng AS shape_leng,
    d.il_shape_area AS shape_area,
    d.geom_lowestres AS geom,
    d.start,
    d.stop
   FROM data.il_2014 d;


--
-- Name: indian_lands_lowres; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW indian_lands_lowres AS
 SELECT d.il_gid AS gid,
    d.il_objectid AS objectid,
    d.il_id AS id,
    d.il_indian AS indian,
    d.il_state AS state,
    d.il_census AS census,
    d.il_gnis AS gnis,
    d.il_name AS name,
    d.il_type AS type,
    d.il_class AS class,
    d.il_recognitio AS recognitio,
    d.il_land_area AS land_area,
    d.il_water_area AS water_area,
    d.il_shape_leng AS shape_leng,
    d.il_shape_area AS shape_area,
    d.geom_lowres AS geom,
    d.start,
    d.stop
   FROM data.il_2014 d;


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
   FROM data.qct d;


--
-- Name: qct_highres_union; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE qct_highres_union (
    gid integer NOT NULL,
    hztype character varying(20) DEFAULT 'qct'::character varying,
    res character varying(10) DEFAULT 'high'::character varying,
    geom geometry(MultiPolygon,4326)
);


--
-- Name: qct_highres_union_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE qct_highres_union_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qct_highres_union_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE qct_highres_union_gid_seq OWNED BY qct_highres_union.gid;


--
-- Name: qct_lowerres; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW qct_lowerres AS
 SELECT d.gid,
    (st_multi(st_simplifypreservetopology(d.geom, (0.001)::double precision)))::geometry(MultiPolygon,4326) AS geom
   FROM data.qct_union d;


--
-- Name: qct_lowestres; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW qct_lowestres AS
 SELECT d.gid,
    (st_multi(st_simplifypreservetopology(d.geom, (0.05)::double precision)))::geometry(MultiPolygon,4326) AS geom
   FROM data.qct_union d;


--
-- Name: qct_lowestres_union; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE qct_lowestres_union (
    gid integer NOT NULL,
    hztype character varying(20) DEFAULT 'qct'::character varying,
    res character varying(10) DEFAULT 'high'::character varying,
    geom geometry(MultiPolygon,4326)
);


--
-- Name: qct_lowestres_union_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE qct_lowestres_union_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qct_lowestres_union_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE qct_lowestres_union_gid_seq OWNED BY qct_lowestres_union.gid;


--
-- Name: qct_lowres; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW qct_lowres AS
 SELECT d.gid,
    (st_multi(st_simplifypreservetopology(d.geom, (0.00005)::double precision)))::geometry(MultiPolygon,4326) AS geom
   FROM data.qct_union d;


--
-- Name: qnmc; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW qnmc AS
 SELECT d.gid,
    d.county,
    d.f2016_sba_,
    d.f2016_sba1,
    d.brac_2016,
    d.geom,
    d.start,
    d.stop
   FROM data.qnmc d;


--
-- Name: qnmc_lowerres; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW qnmc_lowerres AS
 SELECT d.gid,
    (st_multi(st_simplifypreservetopology(d.geom, (0.001)::double precision)))::geometry(MultiPolygon,4326) AS geom
   FROM data.qnmc_union d;


--
-- Name: qnmc_lowestres; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW qnmc_lowestres AS
 SELECT d.gid,
    (st_multi(st_simplifypreservetopology(d.geom, (0.05)::double precision)))::geometry(MultiPolygon,4326) AS geom
   FROM data.qnmc_union d;


--
-- Name: qnmc_lowres; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW qnmc_lowres AS
 SELECT d.gid,
    (st_multi(st_simplifypreservetopology(d.geom, (0.00005)::double precision)))::geometry(MultiPolygon,4326) AS geom
   FROM data.qnmc_union d;


--
-- Name: qnmc_tables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE qnmc_tables (
    id integer NOT NULL
);


--
-- Name: qnmc_tables_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE qnmc_tables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qnmc_tables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE qnmc_tables_id_seq OWNED BY qnmc_tables.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: test; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE test (
    qct_gid integer,
    qct_tract character varying(11),
    qct_state character varying(2),
    qct_city character varying(24),
    qct_county character varying(24),
    qct_qualified_ character varying(4),
    qct_qualified1 character varying(4),
    qct_hubzone_st character varying(32),
    qct_brac_2016 character varying(36),
    geom geometry(MultiPolygon,4326),
    geom_lowres geometry(MultiPolygon,4326),
    geom_lowerres geometry(MultiPolygon,4326),
    geom_lowestres geometry(MultiPolygon,4326),
    start date DEFAULT ('now'::text)::date NOT NULL,
    stop date
);


SET search_path = data, pg_catalog;

--
-- Name: gid; Type: DEFAULT; Schema: data; Owner: -
--

ALTER TABLE ONLY qct_union ALTER COLUMN gid SET DEFAULT nextval('qct_union_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: data; Owner: -
--

ALTER TABLE ONLY qnmc_union ALTER COLUMN gid SET DEFAULT nextval('qnmc_union_gid_seq'::regclass);


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


SET search_path = public, pg_catalog;

--
-- Name: gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY hz_current ALTER COLUMN gid SET DEFAULT nextval('hz_current_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY hz_current_lowerres ALTER COLUMN gid SET DEFAULT nextval('hz_current_lowerres_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY hz_current_lowestres ALTER COLUMN gid SET DEFAULT nextval('hz_current_lowestres_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY hz_current_lowres ALTER COLUMN gid SET DEFAULT nextval('hz_current_lowres_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY qct_highres_union ALTER COLUMN gid SET DEFAULT nextval('qct_highres_union_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY qct_lowestres_union ALTER COLUMN gid SET DEFAULT nextval('qct_lowestres_union_gid_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY qnmc_tables ALTER COLUMN id SET DEFAULT nextval('qnmc_tables_id_seq'::regclass);


SET search_path = data, pg_catalog;

--
-- Name: qct_union_pkey; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY qct_union
    ADD CONSTRAINT qct_union_pkey PRIMARY KEY (gid);


--
-- Name: qnmc_union_pkey; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY qnmc_union
    ADD CONSTRAINT qnmc_union_pkey PRIMARY KEY (gid);


SET search_path = import, pg_catalog;

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
-- Name: hz_current_lowerres_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hz_current_lowerres
    ADD CONSTRAINT hz_current_lowerres_pkey PRIMARY KEY (gid);


--
-- Name: hz_current_lowestres_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hz_current_lowestres
    ADD CONSTRAINT hz_current_lowestres_pkey PRIMARY KEY (gid);


--
-- Name: hz_current_lowres_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hz_current_lowres
    ADD CONSTRAINT hz_current_lowres_pkey PRIMARY KEY (gid);


--
-- Name: hz_current_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hz_current
    ADD CONSTRAINT hz_current_pkey PRIMARY KEY (gid);


--
-- Name: qct_highres_union_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY qct_highres_union
    ADD CONSTRAINT qct_highres_union_pkey PRIMARY KEY (gid);


--
-- Name: qct_lowestres_union_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY qct_lowestres_union
    ADD CONSTRAINT qct_lowestres_union_pkey PRIMARY KEY (gid);


--
-- Name: qnmc_tables_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY qnmc_tables
    ADD CONSTRAINT qnmc_tables_pkey PRIMARY KEY (id);


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

INSERT INTO schema_migrations (version) VALUES ('20161003200320'), ('20161108135805'), ('20161115190127'), ('20161115191042'), ('20161201165108'), ('20161205141123');


