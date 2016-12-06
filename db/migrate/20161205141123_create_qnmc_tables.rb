# A complete hack to get some tests to pass!
#
# Populates the test database with a bounding box region for
# qnmc's that contains the test search used in the integration tests.
#
# The polygon was determined from the actual data via:
#
# SELECT ST_AsText(ST_SetSRID(ST_Extent(geom),4326)) AS geom FROM qnmc WHERE gid = 235;
#
class CreateQnmcTables < ActiveRecord::Migration[5.0]
  def up
    return if Rails.env != "test"

    connection.execute(<<-SQL)
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
           'SRID=4326;MULTIPOLYGON(((-80.280059 38.388457,-80.280059 39.118303,-79.349366 39.118303,-79.349366 38.388457,-80.280059 38.388457)))');

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

  def down
    return if Rails.env != "test"

    connection.execute(<<-SQL)
        DROP VIEW qnmc;
        DROP TABLE data.qnmc;
    SQL
  end
end
