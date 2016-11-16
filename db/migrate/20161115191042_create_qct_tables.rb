# A complete hack to get some tests to pass!
#
# Populates the test database with a bounding box region for a
# qct that contains the test search used in the integration tests.
#
# The polygon was determined from the actual data via:
#
# SELECT ST_AsText(ST_SetSRID(ST_Extent(geom),4326)) AS geom FROM qct WHERE gid = 14426;
#
class CreateQctTables < ActiveRecord::Migration[5.0]
  def up
    return if Rails.env != "test"

    connection.execute(<<-SQL)
        CREATE SCHEMA IF NOT EXISTS data;

        CREATE TABLE IF NOT EXISTS data.qct
        (
          qct_gid integer,
          qct_tract character varying(11),
          qct_state character varying(2),
          qct_city character varying(24),
          qct_county character varying(24),
          qct_qualified_ character varying(4),
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
           'Yes', 'Qualified', NULL,
           'SRID=4326;MULTIPOLYGON(((-76.62264 39.286257,-76.62264 39.295215,-76.605107 39.295215,-76.605107 39.286257,-76.62264 39.286257)))');

        CREATE VIEW qct AS
          SELECT qct_gid        AS gid,
                 qct_tract      AS tract,
                 qct_state      AS state,
                 qct_city       AS city,
                 qct_county     AS county,
                 qct_qualified_ AS qualified_,
                 qct_hubzone_st AS hubzone_st,
                 qct_brac_2016  AS brac_2016,
                 geom,
                 start,
                 stop
            FROM data.qct;
    SQL
  end

  def down
    return if Rails.env != "test"

    connection.execute(<<-SQL)
        DROP VIEW qct;
        DROP TABLE data.qct;
    SQL
  end
end
