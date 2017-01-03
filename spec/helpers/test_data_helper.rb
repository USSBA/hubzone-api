# A complete hack to get some tests to pass!
#
# Populates the test database with bounding box regions for real
# regions that contain the test searches used in the integration tests.
#
# The polygons were determined from the actual data via something like:
#
# SELECT ST_AsText(ST_SetSRID(ST_Extent(geom),4326)) AS geom FROM indian_lands WHERE gid = 275;
#

module TestDataHelper
  def create_test_data
    create_qct_data
    create_qnmc_data
    create_brac_data
    create_indian_lands_data
  end

  def create_qct_data
    ActiveRecord::Base.connection.execute qct_sql
  end

  def qct_sql
    <<-SQL
      CREATE SCHEMA IF NOT EXISTS data;

      CREATE TABLE IF NOT EXISTS data.qct
        (
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
          start date NOT NULL DEFAULT ('now'::text)::date,
          stop date);

        INSERT INTO data.qct VALUES
          (14426, '24510040100',
           'MD', 'Baltimore', 'Baltimore City',
           'Yes', 'Yes', 'Qualified', NULL,
           'SRID=4326;MULTIPOLYGON(((-76.62264 39.286257,-76.62264 39.295215,-76.605107 39.295215,-76.605107 39.286257,-76.62264 39.286257)))'),
          (18606, '72037160100',
           'PR', 'Roosevelt Roads', 'Ceiba',
           'No', 'No', 'Not Qualified', 'Naval Station Roosevelt Roads',
           'SRID=4326;MULTIPOLYGON(((-65.670649 18.198661,-65.670649 18.284649,-65.575676 18.284649,-65.575676 18.198661,-65.670649 18.198661)))'),
          (8190, '05103950100',
           'AR', 'Onalaska', 'Ouachita',
           'No', 'No', 'Not Qualified', 'USARC Camden',
           'SRID=4326;MULTIPOLYGON(((-92.905266 33.54363,-92.905266 33.809988,-92.583054 33.809988,-92.583054 33.54363,-92.905266 33.54363)))'),
          (8134, '40001376900',
           'OK', 'Stilwell', 'Adair',
           'Yes', 'Yes', 'Qualified', NULL,
           'SRID=4326;MULTIPOLYGON(((-94.692669 35.782041,-94.692669 35.841171,-94.594772 35.841171,-94.594772 35.782041,-94.692669 35.782041)))'),
          (3568, '35031943800',
           'NM', 'Nakaibito', 'Mckinley',
           'Yes', 'Yes', 'Qualified', '',
           'SRID=4326;MULTIPOLYGON(((-109.246348 35.659461,-109.246348 38.002881,-108.651412 38.002881,-108.651412 35.659461,-109.246348 35.659461)))'),
          (8177, '05103950200',
           'AR', 'Bragg City', 'Ouachita',
           'No', 'Yes', 'Qualified', '',
           'SRID=4326;MULTIPOLYGON(((-93.11233 33.544939,-93.11233 33.822503,-92.828963 33.822503,-92.828963 33.544939,-93.11233 33.544939)))');

        CREATE VIEW qct AS
          SELECT qct_gid        AS gid,
                 qct_tract      AS tract,
                 qct_state      AS state,
                 qct_city       AS city,
                 qct_county     AS county,
                 qct_qualified_ AS qualified_,
                 qct_qualified1 AS qualified1,
                 qct_hubzone_st AS hubzone_st,
                 qct_brac_2016  AS brac_2016,
                 geom,
                 start,
                 stop
            FROM data.qct;
    SQL
  end

  def create_qnmc_data
    ActiveRecord::Base.connection.execute qnmc_sql
  end

  def qnmc_sql
    <<-SQL
      CREATE SCHEMA IF NOT EXISTS data;

        CREATE TABLE IF NOT EXISTS data.qnmc
        (
          qnmc_gid integer,
          qnmc_county character varying(5),
          qnmc_f2016_sba_ character varying(32),
          qnmc_f2016_sba1 character varying(32),
          qnmc_brac_2016 character varying(36),
          geom geometry(MultiPolygon,4326),
          start date NOT NULL DEFAULT ('now'::text)::date,
          stop date);

        INSERT INTO data.qnmc VALUES
          (235, '40001',
           'Qualified by Unemployment', 'Qualified by Unemployment',
           NULL,
           'SRID=4326;MULTIPOLYGON(((-94.80779 35.638215,-94.80779 36.161902,-94.472647 36.161902,-94.472647 35.638215,-94.80779 35.638215)))'),
          (722, '54075',
           'Redesignated until July 2017', 'Qualified by Unemployment',
           NULL,
           'SRID=4326;MULTIPOLYGON(((-80.363295 38.03611,-80.363295 38.739811,-79.617906 38.739811,-79.617906 38.03611,-80.363295 38.03611)))'),
          (723, '54083',
           'Not Qualified (Non-metropolitan)', 'Not Qualified (Non-metropolitan)',
           'Elkins USARC/OMS, Beverly',
           'SRID=4326;MULTIPOLYGON(((-80.280059 38.388457,-80.280059 39.118303,-79.349366 39.118303,-79.349366 38.388457,-80.280059 38.388457)))'),
          (999, '99999',
           'Qualified by Income', 'Qualified by Income',
           'Douglandia',
           'SRID=4326;MULTIPOLYGON(((-110.000000 34.500000,-110.000000 37.000000,-108.000000 37.000000,-108.000000 34.500000,-110.000000 34.500000)))');

        CREATE VIEW qnmc AS
          SELECT qnmc_gid        AS gid,
                 qnmc_county     AS county,
                 qnmc_f2016_sba_ AS f2016_sba_,
                 qnmc_f2016_sba1 AS f2016_sba1,
                 qnmc_brac_2016  AS brac_2016,
                 geom,
                 start,
                 stop
            FROM data.qnmc;
    SQL
  end

  def create_brac_data
    ActiveRecord::Base.connection.execute brac_sql
  end

  def brac_sql
    <<-SQL
      CREATE SCHEMA IF NOT EXISTS data;

      CREATE TABLE IF NOT EXISTS data.brac
        (
          brac_gid integer,
          brac_sba_name character varying(36),
          brac_county character varying(36),
          brac_st_name character varying(25),
          brac_fac_type character varying(25),
          brac_closure character varying(15),
          geom geometry(MultiPolygon,4326),
          geom_lowres geometry(MultiPolygon,4326),
          geom_lowerres geometry(MultiPolygon,4326),
          geom_lowestres geometry(MultiPolygon,4326),
          start date NOT NULL DEFAULT ('now'::text)::date,
          stop date);

        INSERT INTO data.brac VALUES
          (13, 'Naval Station Roosevelt Roads',
           'Ceiba', 'Puerto Rico', 'Navy Installation',
           '5/7/2015',
           'SRID=4326;MULTIPOLYGON(((-65.687988 18.198784,-65.687988 18.284628,-65.589973 18.284628,-65.589973 18.198784,-65.687988 18.198784)))'),
          (21, 'USARC Camden',
           'Ouachita', 'Arkansas', 'Army Installation',
           '9/12/2011',
           'SRID=4326;MULTIPOLYGON(((-92.769916 33.619565,-92.769916 33.62095,-92.769049 33.62095,-92.769049 33.619565,-92.769916 33.619565)))');

        CREATE VIEW brac AS
          SELECT brac_gid      AS gid,
                 brac_sba_name AS sba_name,
                 brac_county   AS county,
                 brac_st_name  AS st_name,
                 brac_fac_type AS fac_type,
                 brac_closure  AS closure,
                 geom,
                 start,
                 stop
            FROM data.brac;
    SQL
  end

  def create_indian_lands_data
    ActiveRecord::Base.connection.execute indian_lands_sql
  end

  def indian_lands_sql
    <<-SQL
      CREATE TABLE IF NOT EXISTS data.il_2014
        (
          il_gid integer,
          il_objectid integer,
          il_id numeric,
          il_indian character varying(7) COLLATE pg_catalog."default",
          il_state character varying(2) COLLATE pg_catalog."default",
          il_census character varying(7) COLLATE pg_catalog."default",
          il_gnis integer,
          il_name character varying(62) COLLATE pg_catalog."default",
          il_type character varying(37) COLLATE pg_catalog."default",
          il_class character varying(54) COLLATE pg_catalog."default",
          il_recognitio character varying(7) COLLATE pg_catalog."default",
          il_land_area numeric,
          il_water_area numeric,
          il_shape_leng numeric,
          il_shape_area numeric,
          geom geometry(MultiPolygon,4326),
          geom_lowres geometry(MultiPolygon,4326),
          geom_lowerres geometry(MultiPolygon,4326),
          geom_lowestres geometry(MultiPolygon,4326),
          start date NOT NULL DEFAULT ('now'::text)::date,
          stop date);

        INSERT INTO data.il_2014 VALUES
          (275, 275, 1666069.0, '4013905',
            '40', '405560R', 2418814,
            'Cheyenne-Arapaho OK', 'OTSA', 'Oklahoma Tribal Statistical Area', 'Federal',
            8116.89, 59.37,  8.05089172575, 2.10854780235,
            'SRID=4326;MULTIPOLYGON(((-100.000420000183 35.0298010004159,-100.000420000183 36.1657710004314,-97.6739809996234 36.1657710004314,-97.6739809996234 35.0298010004159,-100.000420000183 35.0298010004159)))',
            'SRID=4326;MULTIPOLYGON(((-100.000420000183 35.0298010004159,-100.000420000183 36.1657710004314,-97.6739809996234 36.1657710004314,-97.6739809996234 35.0298010004159,-100.000420000183 35.0298010004159)))',
            'SRID=4326;MULTIPOLYGON(((-100.000420000183 35.0298010004159,-100.000420000183 36.1657710004314,-97.6739809996234 36.1657710004314,-97.6739809996234 35.0298010004159,-100.000420000183 35.0298010004159)))',
            'SRID=4326;MULTIPOLYGON(((-100.000420000183 35.0298010004159,-100.000420000183 36.1657710004314,-97.6739809996234 36.1657710004314,-97.6739809996234 35.0298010004159,-100.000420000183 35.0298010004159)))'),
          (572, 572, 1805572.0, '4013735',
            '40', '405550R', 2418810,
            'Cheyenne OK', 'OTSA', 'Oklahoma Tribal Statistical Area', 'Federal',
            6693.73, 269.48,  8.01175403101, 1.80773742361,
            'SRID=4326;MULTIPOLYGON(((-96.0015720001476 35.2616360004012,-96.0015720001476 36.9996499999476,-94.430662000351 36.9996499999476,-94.430662000351 35.2616360004012,-96.0015720001476 35.2616360004012)))',
            'SRID=4326;MULTIPOLYGON(((-96.0015720001476 35.2616360004012,-96.0015720001476 36.9996499999476,-94.430662000351 36.9996499999476,-94.430662000351 35.2616360004012,-96.0015720001476 35.2616360004012)))',
            'SRID=4326;MULTIPOLYGON(((-96.0015720001476 35.2616360004012,-96.0015720001476 36.9996499999476,-94.430662000351 36.9996499999476,-94.430662000351 35.2616360004012,-96.0015720001476 35.2616360004012)))',
            'SRID=4326;MULTIPOLYGON(((-96.0015720001476 35.2616360004012,-96.0015720001476 36.9996499999476,-94.430662000351 36.9996499999476,-94.430662000351 35.2616360004012,-96.0015720001476 35.2616360004012)))'),
          (515, 515, 1279585, '3551580',
            '35', '352430R', 42851,
            'Navajo Nation NM', 'Reservation', 'American Indian Area (Reservation Only)', 'Federal',
            22237.78, 25.77, 31.0906835145, 1.13921249266,
            'SRID=4326;MULTIPOLYGON(((-110.046782999636 34.3032610000951,-109.046782999636 36.9992870002949,-106.943004999581 36.9992870002949,-106.943004999581 34.3032610000951,-110.046782999636 34.3032610000951)))',
            'SRID=4326;MULTIPOLYGON(((-110.046782999636 34.3032610000951,-109.046782999636 36.9992870002949,-106.943004999581 36.9992870002949,-106.943004999581 34.3032610000951,-110.046782999636 34.3032610000951)))',
            'SRID=4326;MULTIPOLYGON(((-110.046782999636 34.3032610000951,-109.046782999636 36.9992870002949,-106.943004999581 36.9992870002949,-106.943004999581 34.3032610000951,-110.046782999636 34.3032610000951)))',
            'SRID=4326;MULTIPOLYGON(((-110.046782999636 34.3032610000951,-109.046782999636 36.9992870002949,-106.943004999581 36.9992870002949,-106.943004999581 34.3032610000951,-110.046782999636 34.3032610000951)))');

        CREATE VIEW indian_lands AS
          SELECT il_gid         AS gid,
                 il_objectid    AS objectid,
                 il_id          AS id,
                 il_indian      AS indian,
                 il_state       AS state,
                 il_census      AS census,
                 il_gnis        AS gnis,
                 il_name        AS name,
                 il_type        AS type,
                 il_class       AS class,
                 il_recognitio  AS recognitio,
                 il_land_area   AS land_area,
                 il_water_area  AS water_area,
                 il_shape_leng  AS shape_leng,
                 il_shape_area  AS shape_area,
                 geom
            FROM data.il_2014;
    SQL
  end
end
