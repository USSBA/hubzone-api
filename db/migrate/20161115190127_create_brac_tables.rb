# A complete hack to get some tests to pass!
#
# Populates the test database with a bounding box region for a
# brac that contains the test search used in the integration tests.
#
# The polygon was determined from the actual data via:
#
# SELECT ST_AsText(ST_SetSRID(ST_Extent(geom),4326)) AS geom FROM brac WHERE gid = 13;
#
class CreateBracTables < ActiveRecord::Migration[5.0]
  def up
    return if Rails.env != "test"

    connection.execute(<<-SQL)
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
           'SRID=4326;MULTIPOLYGON(((-65.687988 18.198784,-65.687988 18.284628,-65.589973 18.284628,-65.589973 18.198784,-65.687988 18.198784)))');

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

  def down
    return if Rails.env != "test"

    connection.execute(<<-SQL)
        DROP VIEW brac;
        DROP TABLE data.brac;
    SQL
  end
end
