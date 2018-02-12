require 'rails_helper'

test_queries = {
  no_likely_qda: {
    show_likely_qda: false,
    other_information: {
      alerts: { }
    },
    hubzone: [
      {
        'gid' => 51272,
        'tract_fips' => '37179020404',
        'county' => 'Union County',
        'state' => 'NC',
        'omb_delineation' => 'Metropolitan',
        'prior_status' => 'Qualified',
        'current_status' => 'Qualified',
        'status_change' => false,
        'redesignated' => false,
        'expires' => nil,
        'effective' => '2017-01-01',
        'hz_type' => 'qct_e'
      }
    ]
  },
  likely_qda_but_not_qct_or_qnmc_hubzone: {
    show_likely_qda: false,
    other_information: {
      alerts: {
        likely_qda_designations: [
          {
            'gid' => 1428,
            'disaster_state' => 'NC-00081',
            'fema_code' => 4285,
            'disaster_type' => 'PRES_IA',
            'declaration_date' => '2016-10-10',
            'incident_description' => 'Hurricane Matthew',
            'incidence_period' => '10/04/16 - 10/24/16',
            'amendment' => 12,
            'state' => 'NC',
            'county' => 'ANSON',
            'state_fips' => '37',
            'county_fips_3' => '007',
            'effective' => '2017-10-01',
            'county_fips' => '37007',
            'import' => '2017-10-16',
            'import_table' => 'qda_2017_10_01',
            'hz_type' => 'likely_qda',
            'qda_declaration' => '2016-10-10'
          }
        ]
      }
    },
    hubzone: [
      {
        'gid' => 678,
        'brac_id' => 119,
        'brac_sba_name' => 'Roush U.S. Army Reserve Center',
        'tract_fips' => '40039960400',
        'effective' => '2009-10-01',
        'expires' => '2021-12-31',
        'publish_date' => '2016-10-03',
        'qct_data_table' => 'qct_2016_03_01',
        'brac' => true,
        'raw_geom' => nil,
        'closure' => '2009-10-01',
        'county' => 'Custer County',
        'state' => 'OK',
        'fac_type' => 'Army Installation',
        'hz_type' => 'qct_brac'
      },
      {
        'gid' => 73,
        'brac_id' => 119,
        'brac_sba_name' => 'Roush U.S. Army Reserve Center',
        'county_fips' => '40039',
        'effective' => '2009-10-01',
        'expires' => '2021-12-31',
        'publish_date' => '2016-10-03',
        'qnmc_data_table' => 'qnmc_2016_07_01',
        'brac' => true,
        'raw_geom' => nil,
        'fac_type' => 'Army Installation',
        'closure' => '2009-10-01',
        'county' => 'Custer County',
        'state' => 'OK',
        'hz_type' => 'qnmc_brac'
      },
      {
        'gid' => 275,
        'objectid' => 275,
        'id' => '1666069.00000000000',
        'indian' => '4013905',
        'state' => '40',
        'census' => '405560R',
        'gnis' => 2418814,
        'name' => 'Cheyenne-Arapaho OK',
        'type' => 'OTSA',
        'class' => 'Oklahoma Tribal Statistical Area',
        'recognitio' => 'Federal',
        'land_area' => '8116.89000000000',
        'water_area' => '59.37000000000',
        'shape_leng' => '8.05089172575',
        'shape_area' => '2.10854780235',
        'effective' => '2014-01-01',
        'expires' => nil,
        'hz_type' => 'indian_lands'
      }
    ]
  },
  likely_qda_AND_qct_r_or_qnmc_r_hubzone: {
    show_likely_qda: true,
    other_information: {
      alerts: {
        likely_qda_designations: [
          {
            'gid' => 1428,
            'disaster_state' => 'NC-00081',
            'fema_code' => 4285,
            'disaster_type' => 'PRES_IA',
            'declaration_date' => '2016-10-10',
            'incident_description' => 'Hurricane Matthew',
            'incidence_period' => '10/04/16 - 10/24/16',
            'amendment' => 12,
            'state' => 'NC',
            'county' => 'ANSON',
            'state_fips' => '37',
            'county_fips_3' => '007',
            'effective' => '2017-10-01',
            'county_fips' => '37007',
            'import' => '2017-10-16',
            'import_table' => 'qda_2017_10_01',
            'hz_type' => 'likely_qda',
            'qda_declaration' => '2016-10-10'
          }
        ]
      }
    },
    hubzone: [
      {
        'gid' => 1866,
        'tract_fips' => '37007920600',
        'county' => 'Anson County',
        'state' => 'NC',
        'omb_delineation' => 'Non-Metropolitan',
        'prior_status' => 'Not Qualified',
        'current_status' => 'Redesignated Until Dec 2021',
        'status_change' => true,
        'redesignated' => true,
        'expires' => '2021-12-31',
        'effective' => '2017-01-01',
        'hz_type' => 'qct_r'
      }
    ]
  },
  likely_qda_AND_qct_e_or_qnmc_e_hubzone: {
    show_likely_qda: false,
    other_information: {
      alerts: {
        likely_qda_designations: [
          {
            'gid' => 1428,
            'disaster_state' => 'NC-00081',
            'fema_code' => 4285,
            'disaster_type' => 'PRES_IA',
            'declaration_date' => '2016-10-10',
            'incident_description' => 'Hurricane Matthew',
            'incidence_period' => '10/04/16 - 10/24/16',
            'amendment' => 12,
            'state' => 'NC',
            'county' => 'ANSON',
            'state_fips' => '37',
            'county_fips_3' => '007',
            'effective' => '2017-10-01',
            'county_fips' => '37007',
            'import' => '2017-10-16',
            'import_table' => 'qda_2017_10_01',
            'hz_type' => 'likely_qda',
            'qda_declaration' => '2016-10-10'
          }
        ]
      }
    },
    hubzone: [
      {
        'gid' => 1866,
        'tract_fips' => '37007920600',
        'county' => 'Anson County',
        'state' => 'NC',
        'omb_delineation' => 'Non-Metropolitan',
        'prior_status' => 'Not Qualified',
        'current_status' => 'Qualified',
        'status_change' => true,
        'redesignated' => false,
        'expires' => nil,
        'effective' => '2017-01-01',
        'hz_type' => 'qct_e'
      }
    ]
  },
  likely_qda_AND_qct_r_or_qnmc_r_hubzone_AND_qda_hubzones_also_in_likely: {
    show_likely_qda: false,
    other_information: {
      alerts: {
        likely_qda_designations: [
          {
            'gid' => 1043,
            'disaster_state' => 'SC-00040',
            'fema_code' => 4286,
            'disaster_type' => 'PRES_IA',
            'declaration_date' => '2016-10-14',
            'incident_description' => 'Hurricane Matthew',
            'incidence_period' => '10/04/16 - 10/30/16',
            'amendment' => 3,
            'state' => 'SC',
            'county' => 'CHESTERFIELD',
            'state_fips' => '45',
            'county_fips_3' => '025',
            'effective' => '2017-10-01',
            'county_fips' => '45025',
            'import' => '2017-10-16',
            'import_table' => 'qda_2017_10_01',
            'hz_type' => 'likely_qda',
            'qda_declaration' => '2016-10-14'
          }
        ]
      }
    },
    hubzone: [
      {
        'gid' => 59924,
        'tract_fips' => '45025950102',
        'county' => 'Chesterfield County',
        'state' => 'SC',
        'omb_delineation' => 'Non-Metropolitan',
        'prior_status' => 'Qualified',
        'current_status' => 'Redesignated',
        'status_change' => false,
        'redesignated' => true,
        'expires' => nil,
        'effective' => '2017-01-01',
        'hz_type' => 'qct_r'
      },
      {
        'gid' => 206,
        'county_fips' => '45025',
        'qda_id' => 1043,
        'qda_publish' => '2017-09-01',
        'qda_declaration' => '2016-10-14',
        'qnmc_max_expires' => '2017-07-31',
        'qnmc_current_status' => 'not-qualified',
        'qnmc_current_omb' => nil,
        'qda_designation' => '2017-07-31',
        'expires' => '2022-07-31',
        'county' => 'Chesterfield County',
        'state' => 'SC',
        'disaster_state' => 'SC-00040',
        'disaster_type' => 'PRES_IA',
        'fema_code' => 4286,
        'incident_description' => 'Hurricane Matthew',
        'incidence_period' => '10/04/16 - 10/30/16',
        'amendment' => 3,
        'hz_type' => 'qnmc_qda'
      }
    ]
  },
  likely_qda_AND_qct_or_qnmc_hubzone_AND_qda_hubzones_also_in_likely_BUT_also_other_likely_qdas: {
    show_likely_qda: true,
    other_information: {
      alerts: {
        likely_qda_designations: [
          {
            'gid' => 9999,
            'disaster_state' => 'SC-00040',
            'fema_code' => 4286,
            'disaster_type' => 'PRES_IA',
            'declaration_date' => '2016-10-14',
            'incident_description' => 'Hurricane Insane',
            'incidence_period' => '10/04/16 - 10/30/16',
            'amendment' => 3,
            'state' => 'SC',
            'county' => 'CHESTERFIELD',
            'state_fips' => '45',
            'county_fips_3' => '025',
            'effective' => '2017-10-01',
            'county_fips' => '45025',
            'import' => '2017-10-16',
            'import_table' => 'qda_2017_10_01',
            'hz_type' => 'likely_qda',
            'qda_declaration' => '2016-10-14'
          }
        ]
      }
    },
    hubzone: [
      {
        'gid' => 59924,
        'tract_fips' => '45025950102',
        'county' => 'Chesterfield County',
        'state' => 'SC',
        'omb_delineation' => 'Non-Metropolitan',
        'prior_status' => 'Qualified',
        'current_status' => 'Redesignated',
        'status_change' => false,
        'redesignated' => true,
        'expires' => nil,
        'effective' => '2017-01-01',
        'hz_type' => 'qct_r'
      },
      {
        'gid' => 206,
        'county_fips' => '45025',
        'qda_id' => 1043,
        'qda_publish' => '2017-09-01',
        'qda_declaration' => '2016-10-14',
        'qnmc_max_expires' => '2017-07-31',
        'qnmc_current_status' => 'not-qualified',
        'qnmc_current_omb' => nil,
        'qda_designation' => '2017-07-31',
        'expires' => '2022-07-31',
        'county' => 'Chesterfield County',
        'state' => 'SC',
        'disaster_state' => 'SC-00040',
        'disaster_type' => 'PRES_IA',
        'fema_code' => 4286,
        'incident_description' => 'Hurricane Matthew',
        'incidence_period' => '10/04/16 - 10/30/16',
        'amendment' => 3,
        'hz_type' => 'qnmc_qda'
      }
    ]
  }
}

RSpec.describe VerifiedHubzone, type: :model do
  test_queries.map do |query_context, query|
    context "Given a hubzone assertion with #{query_context}" do
      let(:verified_hubzone) { (VerifiedHubzone.new query).hubzone_results }

      it "#{query[:show_likely_qda] ? '"WILL"' : '"WONT"'} show a likely_qda" do
        expect(verified_hubzone.dig(:other_information, :alerts, :likely_qda_designations).present?).to be(query[:show_likely_qda])
      end
    end
  end
end
