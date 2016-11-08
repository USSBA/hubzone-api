# A complete hack to get some tests to pass!
#
# Populates the test database with two bounding box regions for real indian lands
# regions that contain the test searches used in the integration tests.
#
# The polygons were determined from the actual data via:
#
# SELECT ST_AsText(ST_SetSRID(ST_Extent(geom),4326)) AS geom FROM indian_lands WHERE gid = 275;
#
class CreateIndianLandsTables < ActiveRecord::Migration[5.0]
  def up
    if Rails.env == "test"
      self.connection.execute(<<-SQL)
        CREATE SCHEMA IF NOT EXISTS data;

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
          (515, 515, 1279585, '3551580',
            '35', '352430R', 42851,
            'Navajo Nation NM', 'Reservation', 'American Indian Area (Reservation Only)', 'Federal',
            22237.78, 25.77, 31.0906835145, 1.13921249266,
            'SRID=4326;MULTIPOLYGON(((-109.046782999636 34.3032610000951,-109.046782999636 36.9992870002949,-106.943004999581 36.9992870002949,-106.943004999581 34.3032610000951,-109.046782999636 34.3032610000951)))',
            'SRID=4326;MULTIPOLYGON(((-109.046782999636 34.3032610000951,-109.046782999636 36.9992870002949,-106.943004999581 36.9992870002949,-106.943004999581 34.3032610000951,-109.046782999636 34.3032610000951)))',
            'SRID=4326;MULTIPOLYGON(((-109.046782999636 34.3032610000951,-109.046782999636 36.9992870002949,-106.943004999581 36.9992870002949,-106.943004999581 34.3032610000951,-109.046782999636 34.3032610000951)))',
            'SRID=4326;MULTIPOLYGON(((-109.046782999636 34.3032610000951,-109.046782999636 36.9992870002949,-106.943004999581 36.9992870002949,-106.943004999581 34.3032610000951,-109.046782999636 34.3032610000951)))');

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

  def down
    if Rails.env == "test"
      self.connection.execute(<<-SQL)
        DROP VIEW indian_lands;
        DROP TABLE data.il_2014;
      SQL
    end
  end
end
