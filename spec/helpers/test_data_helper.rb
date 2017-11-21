# A complete hack to get some tests to pass!
#
# Populates the test database with bounding box regions for real
# regions that contain the test searches used in the integration tests.
#
# The polygons were determined from the actual data via something like:
#
# SELECT ST_AsText(ST_SetSRID(ST_Extent(geom),4326)) AS geom FROM indian_lands WHERE gid = 275;
#

# rubocop:disable Metrics/ModuleLength
module TestDataHelper
  def create_test_data
    create_qct_data
    create_qct_brac_data
    create_qct_qda_data
    create_qnmc_data
    create_qnmc_brac_data
    create_qnmc_qda_data
    create_brac_data
    create_indian_lands_data
    create_likely_qda_data
    create_congressional_district_data
  end

  def create_qct_data
    ActiveRecord::Base.connection.execute qct_sql
  end

  def qct_sql
    <<-SQL
      CREATE SCHEMA IF NOT EXISTS data;

      CREATE TABLE IF NOT EXISTS data.qct
        (
          gid integer,
          tract_fips character varying(11),
          state character varying(2),
          city character varying(24),
          county character varying(24),
          qualified_ character varying(4),
          qualified1 character varying(4),
          current_status character varying(32),
          brac_2016 character varying(36),
          redesignated boolean,
          brac_id integer,
          geom geometry(MultiPolygon,4326),
          effective date NOT NULL DEFAULT ('now'::text)::date,
          expires date);

        INSERT INTO data.qct VALUES
          -- qct_e in baltimore
          (14426, '24510040100',
           'MD', 'Baltimore', 'Baltimore City',
           'Yes', 'Yes', 'Qualified', NULL,
           false, null,
           'SRID=4326;MULTIPOLYGON(((-76.62264 39.286257,-76.62264 39.295215,-76.605107 39.295215,-76.605107 39.286257,-76.62264 39.286257)))',
           ('now'::text)::date, null),

          -- qct_r in baltimore
          (14532, '24005450504',
           'MD', 'Hartland Village', 'Baltimore',
           'No', 'No', 'edesignated until Jan. 2018', NULL,
           true, NULL,
           'SRID=4326;MULTIPOLYGON(((-76.451331 39.293449,-76.451331 39.31303,-76.43777 39.31303,-76.43777 39.293449,-76.451331 39.293449)))',
           ('now'::text)::date, '2019-10-15'),

          -- qct_e in stilwell ok
          (8134, '40001376900',
           'OK', 'Stilwell', 'Adair',
           'Yes', 'Yes', 'Qualified', NULL,
           false, NULL,
           'SRID=4326;MULTIPOLYGON(((-94.692669 35.782041,-94.692669 35.841171,-94.594772 35.841171,-94.594772 35.782041,-94.692669 35.782041)))',
           ('now'::text)::date, null),

          -- qct_e in new mexico, navajo
          (3568, '35031943800',
           'NM', 'Nakaibito', 'Mckinley',
           'Yes', 'Yes', 'Qualified', '',
           false, NULL,
           'SRID=4326;MULTIPOLYGON(((-109.246348 35.659461,-109.246348 38.002881,-108.651412 38.002881,-108.651412 35.659461,-109.246348 35.659461)))',
           ('now'::text)::date, null),

          -- qct_e in adel, ga
          (21795, '13075960200',
           'GA', '', 'Cook',
           'Yes', 'Yes', 'Qualified', '',
           false, NULL,
           'SRID=4326;MULTIPOLYGON(((-83.576516 31.027288,-83.576516 31.350295,-83.280839 31.350295,-83.280839 31.027288,-83.576516 31.027288)))',
           ('now'::text)::date, null),

          -- qct not brac
          (8177, '05103950200',
           'AR', 'Bragg City', 'Ouachita',
           'No', 'Yes', 'Qualified', '',
           false, NULL,
           'SRID=4326;MULTIPOLYGON(((-93.11233 33.544939,-93.11233 33.822503,-92.828963 33.822503,-92.828963 33.544939,-93.11233 33.544939)))',
           ('now'::text)::date, null),

          -- qct_r in pine view tn
          (3690, '47135930100',
           'TN', 'Pine View', 'Perry',
           'No', 'Yes', 'Qualified', '',
           true, NULL,
           'SRID=4326;MULTIPOLYGON(((-88.032842 35.645434,-88.032842 35.840593,-87.709976 35.840593,-87.709976 35.645434,-88.032842 35.645434)))',
           ('now'::text)::date, '2018-01-31'),

          -- qct_r in warden wa
          (3915, '53025011300',
           'WA', 'Warden', 'Grant',
           'No', 'Yes', 'Redesignated until Jan 2018', '',
           true, NULL,
           'SRID=4326;MULTIPOLYGON(((-119.265898 46.91133,-119.265898 47.087106,-118.98108 47.087106,-118.98108 46.91133,-119.265898 46.91133)))',
           ('now'::text)::date, '2018-01-31');

        CREATE VIEW qct AS
          SELECT *
            FROM data.qct;
    SQL
  end

  def create_qct_brac_data
    ActiveRecord::Base.connection.execute qct_brac_sql
  end

  def qct_brac_sql
    <<-SQL
      CREATE SCHEMA IF NOT EXISTS data;

      CREATE TABLE IF NOT EXISTS data.qct_brac
        (
          gid integer,
          tract_fips character varying(11),
          state character varying(2),
          city character varying(24),
          county character varying(24),
          fac_type varchar,
          qualified_ character varying(4),
          qualified1 character varying(4),
          current_status character varying(32),
          brac_sba_name character varying(36),
          redesignated boolean,
          brac_id integer,
          closure date,
          geom geometry(MultiPolygon,4326),
          effective date NOT NULL DEFAULT ('now'::text)::date,
          expires date);

        INSERT INTO data.qct_brac VALUES
          -- qct_brac puerto rico
          (18606, '72037160100',
           'PR', 'Roosevelt Roads', 'Ceiba', 'Naval Installation',
           'No', 'No', 'Not Qualified', 'Naval Station Roosevelt Roads',
           false, 13, '2013-01-01',
           'SRID=4326;MULTIPOLYGON(((-65.670649 18.198661,-65.670649 18.284649,-65.575676 18.284649,-65.575676 18.198661,-65.670649 18.198661)))',
           ('now'::text)::date, '2020-09-15'),

          -- qct_brac in Amy AR
          (8190, '05103950100',
           'AR', 'Onalaska', 'Ouachita', 'Naval Installation',
           'No', 'No', 'Not Qualified', 'USARC Camden',
           false, 21, '2013-01-01',
           'SRID=4326;MULTIPOLYGON(((-92.905266 33.54363,-92.905266 33.809988,-92.583054 33.809988,-92.583054 33.54363,-92.905266 33.54363)))',
           ('now'::text)::date, '2021-11-05');

        CREATE VIEW qct_brac AS
          SELECT *
            FROM data.qct_brac;
    SQL
  end

  def create_qnmc_data
    ActiveRecord::Base.connection.execute qnmc_sql
  end

  def qnmc_sql
    <<-SQL
      CREATE SCHEMA IF NOT EXISTS data;

        CREATE TABLE IF NOT EXISTS data.qnmc_2016_01_01
        (
          gid integer,
          county_fips character varying(5),
          county character varying(32),
          state character varying(2),
          f2016_sba_ varchar,
          f2016_sba1 varchar,
          brac_2016 character varying(36),
          redesignated boolean,
          income boolean,
          unemployment boolean,
          dda boolean,
          brac_id integer,
          geom geometry(MultiPolygon,4326),
          start date NOT NULL DEFAULT ('now'::text)::date,
          expires date);

        INSERT INTO data.qnmc_2016_01_01 VALUES
          -- qnmc_a in stilwell ok
          (235, '40001', 'Stilwell', 'OK',
           'Qualified by income', 'Qualified by income',
           NULL,
           false, true, false,false, NULL,
           'SRID=4326;MULTIPOLYGON(((-94.80779 35.638215,-94.80779 36.161902,-94.472647 36.161902,-94.472647 35.638215,-94.80779 35.638215)))',
           ('now'::text)::date, null),

          -- qnmc_b in navajo
          (999, '99999', 'Navajo', 'AZ',
           'Qualified by Unemployment', 'Qualified by Unemployment',
           NULL,
           false, false, true, false, NULL,
           'SRID=4326;MULTIPOLYGON(((-110.000000 34.500000,-110.000000 37.000000,-108.000000 37.000000,-108.000000 34.500000,-110.000000 34.500000)))',
           ('now'::text)::date, null),

          -- qnmc_c in buckeye wv
          (722, '54075', 'Buckeye', 'WV',
           'Redesignated until July 2017', 'Qualified by dda',
           NULL,
           false, false, false, true, NULL,
           'SRID=4326;MULTIPOLYGON(((-80.363295 38.03611,-80.363295 38.739811,-79.617906 38.739811,-79.617906 38.03611,-80.363295 38.03611)))',
           ('now'::text)::date, null),

          -- qnmc_ab in McDowell County,WV
          (3016, '54047', 'Buckeye', 'WV',
           'Redesignated until July 2017', 'Qualified by income and Unemployment',
           NULL,
           false, true, true, false, NULL,
           'SRID=4326;MULTIPOLYGON(((-81.996578 37.20154,-81.996578 37.54901,-81.311201 37.54901,-81.311201 37.20154,-81.996578 37.20154)))',
           ('now'::text)::date, null),

          -- qnmc_ac (this is a fake one, not currently any qnmc_ac designations in the DB)
          (1194, '24031', 'Montgomery County', 'MD',
           'Qualified by Income and DDA', 'Qualified by Income and DDA',
           NULL,
           false, true, false, true, NULL,
           'SRID=4326;MULTIPOLYGON(((-77.526786 38.935356,-77.526786 39.353502,-76.888628 39.353502,-76.888628 38.935356,-77.526786 38.935356)))',
           ('now'::text)::date, null),

          -- qnmc_bc Las Marias PR
          (3195, '72083', 'Las Marias Municipio', 'PR',
           'Qualified by Unemployment and DDA', 'Qualified by Unemployment and DDA',
           NULL,
           false, false, true, true, NULL,
           'SRID=4326;MULTIPOLYGON(((-67.082002 18.187744,-67.082002 18.289867,-66.897964 18.289867,-66.897964 18.187744,-67.082002 18.187744)))',
           ('now'::text)::date, null),

          -- qnmc_abc in Nome Census Area,AK
          (85, '02180', 'Nome Census Area', 'AK',
           'Qualified by Income and Unemployment and DDA', 'Qualified by Income and Unemployment and DDA',
           NULL,
           false, true, true, true, NULL,
           'SRID=4326;MULTIPOLYGON(((-171.849984 62.937527,-171.849984 66.581706,-159.37937 66.581706,-159.37937 62.937527,-171.849984 62.937527)))',
           ('now'::text)::date, null),

          -- What happens if there is a hubzone with all false designations
          (85, '22109', 'Terrebonne Parish', 'LA',
           'Not-Qualified', 'Not-Qualified',
           NULL,
           false, false, false, false, NULL,
           'SRID=4326;MULTIPOLYGON(((-91.353067 29.03658,-91.353067 29.778008,-90.376573 29.778008,-90.376573 29.03658,-91.353067 29.03658)))',
           ('now'::text)::date, null),

           -- qnmc_r in pine view tn
           (2496, '47135', 'Pine View', 'TN',
           'Redesignated until July 2018', 'Redesignated until July 2018',
           NULL,
           true, false, false, false, NULL,
           'SRID=4326;MULTIPOLYGON(((-88.042086 35.424525,-88.042086 35.840593,-87.648488 35.840593,-87.648488 35.424525,-88.042086 35.424525)))',
           ('now'::text)::date, '2018-07-31'),

          -- qnmc_r in florida that will get likely_qda
           (2497, '12099', 'Palm Beach', 'FL',
           'Redesignated until July 2018', 'Redesignated until July 2018',
           NULL,
           true, false, false, false, NULL,
           'SRID=4326;MULTIPOLYGON(((-80.886232 26.320755,-80.886232 26.970943,-80.031362 26.970943,-80.031362 26.320755,-80.886232 26.320755)))',
           ('now'::text)::date, '2018-07-31');

        CREATE VIEW qnmc AS
          SELECT *
            FROM data.qnmc_2016_01_01;
    SQL
  end

  def create_qnmc_brac_data
    ActiveRecord::Base.connection.execute qnmc_brac_sql
  end

  def qnmc_brac_sql
    <<-SQL
      CREATE SCHEMA IF NOT EXISTS data;

        CREATE TABLE IF NOT EXISTS data.qnmc_brac
        (
          gid integer,
          county_fips character varying(5),
          county varchar,
          state varchar,
          fac_type varchar,
          f2016_sba_ character varying(32),
          f2016_sba1 character varying(32),
          brac_sba_name character varying(36),
          redesignated boolean,
          income boolean,
          unemployment boolean,
          dda boolean,
          brac_id integer,
          closure date,
          geom geometry(MultiPolygon,4326),
          effective date NOT NULL DEFAULT ('now'::text)::date,
          expires date);

        INSERT INTO data.qnmc_brac VALUES
          -- qnmc_brac in mabie, WV
          (723, '54083', 'Mabie', 'WV', 'Army Installation',
           'Not Qualified (Non-metropolitan)', 'Not Qualified (Non-metropolitan)',
           'Elkins USARC/OMS, Beverly',
           false, false, false, false, 1, '2013-01-01',
           'SRID=4326;MULTIPOLYGON(((-80.280059 38.388457,-80.280059 39.118303,-79.349366 39.118303,-79.349366 38.388457,-80.280059 38.388457)))',
           ('now'::text)::date,'2020-04-16'),

           -- qnmc_brac in Warden WA
           (453, '53025', 'Warden', 'WA', 'Army Installation',
           'Not Qualified (Non-metropolitan)', 'Not Qualified (Non-metropolitan)',
           'Wagener USARC, Pasco',
           false, false, false, false, 60, '2013-01-01',
           'SRID=4326;MULTIPOLYGON(((-120.035858 46.62578,-120.035858 47.962152,-118.973572 47.962152,-118.973572 46.62578,-120.035858 46.62578)))',
           ('now'::text)::date,'2020-12-31');


        CREATE VIEW qnmc_brac AS
          SELECT *
            FROM data.qnmc_brac;
    SQL
  end

  def create_qnmc_qda_data
    ActiveRecord::Base.connection.execute qnmc_qda_sql
  end

  def qnmc_qda_sql
    <<-SQL
      CREATE SCHEMA IF NOT EXISTS data;

        CREATE TABLE IF NOT EXISTS data.qnmc_qda (
          gid SERIAL primary key,
          county_fips varchar,
          county varchar,
          state varchar,
          qda_id int,
          qda_publish date,
          qda_declaration date,
          qnmc_max_expires date,
          qnmc_current_status varchar,
          qnmc_current_omb varchar,
          qda_designation date,
          expires date,
          incident_description varchar,
          geom geometry('MULTIPOLYGON', 4326));

        INSERT INTO data.qnmc_qda VALUES
          -- qnmc_qda in adel ga
          (17,'13075', 'Adel', 'GA', 84,'2017-03-01','2017-01-26','2016-07-31','not-qualified','Non-metropolitan','2017-01-26','2022-01-26',
           'Hurricane Insane',
           'SRID=4326;MULTIPOLYGON(((-83.576516 31.027288,-83.576516 31.350295,-83.280839 31.350295,-83.280839 31.027288,-83.576516 31.027288)))'),
          -- qnmc_qda in rockyhock NC
          (36,'37091', 'Rockyhock', 'NC', 191,'2017-03-01','2016-10-10','2016-01-31','not-qualified','Non-metropolitan','2016-10-10','2021-10-10',
           'Hurricane Insane',
           'SRID=4326;MULTIPOLYGON(((-76.72229 36.006148,-76.72229 36.351892,-76.408389 36.351892,-76.408389 36.006148,-76.72229 36.006148)))'),
          -- qnmc_qda in harrelsville NC
          (15,'37041', 'Harrelsville', 'NC', 76,'2016-11-01','2016-10-10','2013-10-31','not-qualified','Non-metropolitan','2016-10-10','2021-10-10',
           'Hurricane Insane',
           'SRID=4326;MULTIPOLYGON(((-77.20879 36.238234,-77.20879 36.54633,-76.698309 36.54633,-76.698309 36.238234,-77.20879 36.238234)))');

        CREATE VIEW qnmc_qda AS
          SELECT *
            FROM data.qnmc_qda;
    SQL
  end

  def create_qct_qda_data
    ActiveRecord::Base.connection.execute qct_qda_sql
  end

  def qct_qda_sql
    <<-SQL
      CREATE SCHEMA IF NOT EXISTS data;

        CREATE TABLE IF NOT EXISTS data.qct_qda (
          gid SERIAL primary key,
          county_fips varchar,
          tract_fips varchar,
          county varchar,
          state varchar,
          qda_id int,
          qda_publish date,
          qda_declaration date,
          qct_max_expires date,
          qct_current_status varchar,
          qda_designation date,
          expires date,
          incident_description varchar,
          geom geometry('MULTIPOLYGON', 4326));

        INSERT INTO data.qct_qda VALUES
          -- qct_qda in mcbee sc
          (76,'45025','45025950800', 'McBee', 'SC', 43,'2016-11-01','2016-10-14','2015-10-31','not-qualified','2016-10-14','2021-10-14',
           'Hurricane Insane',
           'SRID=4326;MULTIPOLYGON(((-80.359638 34.366207,-80.359638 34.630704,-80.153734 34.630704,-80.153734 34.366207,-80.359638 34.366207)))'),

          -- qct_qda in mcbee sc on a later date
          (77,'45025','45025950800', 'McBee', 'SC', 43,'2017-01-01','2016-12-25','2015-10-31','not-qualified','2016-12-25','2021-12-25',
           'Hurricane Insane',
           'SRID=4326;MULTIPOLYGON(((-80.359638 34.366207,-80.359638 34.630704,-80.153734 34.630704,-80.153734 34.366207,-80.359638 34.366207)))');

        CREATE VIEW qct_qda AS
          SELECT *
            FROM data.qct_qda;
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
          gid integer,
          sba_name character varying(36),
          county character varying(36),
          st_name character varying(25),
          fac_type character varying(25),
          effective character varying(15),
          closure date,
          geom geometry(MultiPolygon,4326),
          expires date);

        INSERT INTO data.brac VALUES
          (13, 'Naval Station Roosevelt Roads',
           'Ceiba', 'Puerto Rico', 'Navy Installation',
           '5/7/2015', '2013-01-01',
           'SRID=4326;MULTIPOLYGON(((-65.687988 18.198784,-65.687988 18.284628,-65.589973 18.284628,-65.589973 18.198784,-65.687988 18.198784)))',
           '2020-09-15'),
          (21, 'USARC Camden',
           'Ouachita', 'Arkansas', 'Army Installation',
           '9/12/2011', '2013-01-01',
           'SRID=4326;MULTIPOLYGON(((-92.769916 33.619565,-92.769916 33.62095,-92.769049 33.62095,-92.769049 33.619565,-92.769916 33.619565)))',
           '2020-08-15');

        CREATE VIEW brac AS
          SELECT *
            FROM data.brac;
    SQL
  end

  def create_indian_lands_data
    ActiveRecord::Base.connection.execute indian_lands_sql
  end

  def indian_lands_sql
    <<-SQL
      CREATE TABLE IF NOT EXISTS data.indian_lands
        (
          gid integer,
          objectid integer,
          id numeric,
          indian character varying(7) COLLATE pg_catalog."default",
          state character varying(2) COLLATE pg_catalog."default",
          census character varying(7) COLLATE pg_catalog."default",
          gnis integer,
          name character varying(62) COLLATE pg_catalog."default",
          type character varying(37) COLLATE pg_catalog."default",
          class character varying(54) COLLATE pg_catalog."default",
          recognitio character varying(7) COLLATE pg_catalog."default",
          land_area numeric,
          water_area numeric,
          shape_leng numeric,
          shape_area numeric,
          geom geometry(MultiPolygon,4326),
          start date NOT NULL DEFAULT ('now'::text)::date,
          stop date,
          expires date);

        INSERT INTO data.indian_lands VALUES
          (275, 275, 1666069.0, '4013905',
            '40', '405560R', 2418814,
            'Cheyenne-Arapaho OK', 'OTSA', 'Oklahoma Tribal Statistical Area', 'Federal',
            8116.89, 59.37,  8.05089172575, 2.10854780235,
            'SRID=4326;MULTIPOLYGON(((-100.000420000183 35.0298010004159,-100.000420000183 36.1657710004314,-97.6739809996234 36.1657710004314,-97.6739809996234 35.0298010004159,-100.000420000183 35.0298010004159)))',
            ('now'::text)::date, '2020-05-14', null),
          (572, 572, 1805572.0, '4013735',
            '40', '405550R', 2418810,
            'Cheyenne OK', 'OTSA', 'Oklahoma Tribal Statistical Area', 'Federal',
            6693.73, 269.48,  8.01175403101, 1.80773742361,
            'SRID=4326;MULTIPOLYGON(((-96.0015720001476 35.2616360004012,-96.0015720001476 36.9996499999476,-94.430662000351 36.9996499999476,-94.430662000351 35.2616360004012,-96.0015720001476 35.2616360004012)))',
            ('now'::text)::date, '2020-05-14', null),
          (515, 515, 1279585, '3551580',
            '35', '352430R', 42851,
            'Navajo Nation NM', 'Reservation', 'American Indian Area (Reservation Only)', 'Federal',
            22237.78, 25.77, 31.0906835145, 1.13921249266,
            'SRID=4326;MULTIPOLYGON(((-110.046782999636 34.3032610000951,-109.046782999636 36.9992870002949,-106.943004999581 36.9992870002949,-106.943004999581 34.3032610000951,-110.046782999636 34.3032610000951)))',
            ('now'::text)::date, '2020-05-14', null);

        CREATE VIEW indian_lands AS
          SELECT *
            FROM data.indian_lands;
    SQL
  end

  # create several likley qda records
  def create_likely_qda_data
    ActiveRecord::Base.connection.execute likely_qda_sql
  end

  def likely_qda_sql
    <<-SQL
      CREATE TABLE IF NOT EXISTS data.likely_qda
      (
        gid integer,
        disaster_state varchar,
        fema_code integer,
        disaster_type varchar,
        declaration_date date,
        qda_declaration date,
        incident_description varchar,
        incidence_period varchar,
        amendment integer,
        state varchar,
        county varchar,
        state_fips varchar,
        county_fips_3 varchar,
        effective date,
        county_fips varchar,
        import date,
        import_table varchar,
        geom geometry(MultiPolygon,4326)
      );

      INSERT INTO data.likely_qda VALUES
        (1160,'FL-00130',4337,'PRES_IA','2017-09-10'::date,'2017-09-10'::date,'Hurricane Irma','09/04/17 -',0,'FL','COLLIER',
          '12','021','2017-10-01'::date,'12021','2017-10-06'::date,'qda_2017_10_01',
          'SRID=4326;MULTIPOLYGON(((-81.8459 25.803038,-81.8459 26.517069,-80.872748 26.517069,-80.872748 25.803038,-81.8459 25.803038)))'),
        (1172,'FL-00130',4337,'PRES_IA','2017-09-10'::date,'2017-09-10'::date,'Hurricane Irma','09/04/17 -',1,'FL','PALM BEACH',
          '12','099','2017-10-01'::date,'12099','2017-10-06'::date,'qda_2017_10_01',
          'SRID=4326;MULTIPOLYGON(((-80.886232 26.320755,-80.886232 26.970943,-80.031362 26.970943,-80.031362 26.320755,-80.886232 26.320755)))'),
        (1164,'FL-00130',4337,'PRES_IA','2017-09-10'::date,'2017-09-10'::date,'Hurricane Irma','09/04/17 -',0,'FL','MIAMI-DADE',
          '12','086','2017-10-01'::date,'12086','2017-10-06'::date,'qda_2017_10_01',
          'SRID=4326;MULTIPOLYGON(((-80.8736 25.13742,-80.8736 25.979434,-80.118009 25.979434,-80.118009 25.13742,-80.8736 25.13742)))'),
        (1178,'FL-00130',4337,'PRES_IA','2017-09-10'::date,'2017-09-10'::date,'Hurricane Irma','09/04/17 -',2,'FL','POLK',
          '12','105','2017-10-01'::date,'12105','2017-10-06'::date,'qda_2017_10_01',
          'SRID=4326;MULTIPOLYGON(((-82.106236 27.643238,-82.106236 28.361868,-81.131044 28.361868,-81.131044 27.643238,-82.106236 27.643238)))');

      CREATE VIEW likely_qda AS
          SELECT *
            FROM data.likely_qda;
    SQL
  end

  def create_congressional_district_data
    ActiveRecord::Base.connection.execute congressional_district_sql
  end

  def congressional_district_sql
    <<-SQL
      CREATE TABLE IF NOT EXISTS data.congressional_districts
      (
        gid integer,
        statefp varchar,
        cd115fp varchar,
        geoid varchar,
        namelsad varchar,
        lsad varchar,
        cdsessn varchar,
        mtfcc varchar,
        funcstat varchar,
        aland numeric,
        awater numeric,
        intptlat varchar,
        intptlon varchar,
        geom geometry(MultiPolygon, 4326),
        effective date,
        state varchar
      );

      INSERT INTO data.congressional_districts VALUES
      (278,'25','09','2509','Congressional District 9','C2','115','G5200','N',3149602733,5148720788,'41.6903601','-070.4943141',
      'SRID=4326;MULTIPOLYGON(((-71.201162 41.187053,-71.201162 42.195372,-69.858861 42.195372,-69.858861 41.187053,-71.201162 41.187053)))',
      '2017-10-18'::date,'MA');

      CREATE VIEW congressional_districts AS
        SELECT *
          FROM data.congressional_districts;

    SQL
  end
end
