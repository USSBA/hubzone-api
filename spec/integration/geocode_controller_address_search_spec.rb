require 'rails_helper'
require 'helpers/test_data_helper'

RSpec.configure do |c|
  c.include TestDataHelper
end

def search_url
  api_search_url
end

def headers_arg(version = 1)
  {'Accept' => "application/sba.hubzone-api.v#{version}"}
end

required_fields = {
  qct_e: %w[tract_fips county state],
  qct_r: %w[tract_fips county state],
  qnmc_a: %w[county_fips county state],
  qnmc_b: %w[county_fips county state],
  qnmc_c: %w[county_fips county state],
  qnmc_ab: %w[county_fips county state],
  qnmc_ac: %w[county_fips county state],
  qnmc_bc: %w[county_fips county state],
  qnmc_abc: %w[county_fips county state],
  qnmc_r: %w[county_fips county state],
  indian_lands: %w[name census type class gnis],
  brac: %w[brac_sba_name fac_type effective closure],
  qct_brac: %w[brac_sba_name fac_type effective tract_fips county state closure],
  qnmc_brac: %w[brac_sba_name fac_type effective county_fips county state closure],
  qct_qda: %w[incident_description qda_declaration qda_designation qda_publish tract_fips county state],
  qnmc_qda: %w[incident_description qda_declaration qda_designation qda_publish county_fips county state],
  non_qnmc: %w[county_fips county state],
  mvw_gov_area_map: %w[state_fip county_fip tract_code date_approve]
}

test_queries = {
  qct: {
    context: 'in a QCT in baltimore',
    query: '8 Market Place Baltimore MD 21202',
    lat: '39.2888915',
    lng: '-76.6069962',
    http_status: 200,
    results_address: '8 Market Pl, Baltimore, MD 21202, USA',
    designations: %w[qct_e],
    until_date: nil,
    response: {
      status: "OK",
      http_status: 200,
      formatted_address: "8 Market Pl, Baltimore, MD 21202, USA",
      other_information: {"alerts": {}, "congressional_district": []},
      hubzone: [
        {
          "gid": 14426,
          "tract_fips": "24510040100",
          "state": "MD",
          "city": "Baltimore",
          "county": "Baltimore City",
          "qualified_": "Yes",
          "qualified1": "Yes",
          "current_status": "Qualified",
          "brac_2016": nil,
          "redesignated": false,
          "brac_id": nil,
          "effective": "2017-10-23",
          "expires": nil,
          "hz_type": "qct_e"
        }
      ],
      until_date: nil,
      query_date: nil,
      search_q: "8 Market Place Baltimore MD 21202",
      search_latlng: nil,
      api_version: 1
    }
  },
  roosevelt: {
    context: 'for a location in a BRAC, in a CT that is only BRAC designated',
    query: 'Roosevelt Roads, Ceiba, Puerto Rico',
    lat: '18.237248',
    lng: '-65.6480292',
    http_status: 200,
    results_address: 'Roosevelt Roads, Ceiba, Puerto Rico',
    designations: %w[brac qct_brac],
    until_date: '2020-09-15',
    response: {
      formatted_address: "Roosevelt Roads, Ceiba, Puerto Rico",
      status: "OK",
      http_status: 200,
      other_information: {"alerts": {}, "congressional_district": []},
      hubzone: [
        {
          "gid": 13,
          "sba_name": "Naval Station Roosevelt Roads",
          "county": "Ceiba",
          "st_name": "Puerto Rico",
          "fac_type": "Navy Installation",
          "effective": "5/7/2015",
          "closure": "2013-01-01",
          "expires": "2020-09-15",
          "hz_type": "brac",
          "brac_sba_name": "Naval Station Roosevelt Roads"
        },
        {
          "gid": 18606,
          "tract_fips": "72037160100",
          "state": "PR",
          "city": "Roosevelt Roads",
          "county": "Ceiba",
          "fac_type": "Naval Installation",
          "qualified_": "No",
          "qualified1": "No",
          "current_status": "Not Qualified",
          "brac_sba_name": "Naval Station Roosevelt Roads",
          "redesignated": false,
          "brac_id": 13,
          "closure": "2013-01-01",
          "effective": "2017-10-24",
          "expires": "2020-09-15",
          "hz_type": "qct_brac"
        }
      ],
      until_date: "2020-09-15",
      query_date: nil,
      search_q: "Roosevelt Roads, Ceiba, Puerto Rico",
      search_latlng: nil,
      api_version: 1
    }
  },
  qct_qda: {
    context: 'of mcbee SC where there are two qct_qda designations',
    query: 'McBee, SC 29101, USA',
    lat: '34.4690418',
    lng: '-80.2559033',
    http_status: 200,
    results_address: 'McBee, SC 29101, USA',
    designations: %w[qct_qda qct_qda],
    until_date: '2021-12-25',
    response: {
      formatted_address: "McBee, SC 29101, USA",
      types: %w[locality political],
      status: "OK",
      http_status: 200,
      other_information: {"alerts": {}, "congressional_district": []},
      hubzone: [
        {
          "gid": 76,
          "county_fips": "45025",
          "tract_fips": "45025950800",
          "county": "McBee",
          "state": "SC",
          "qda_id": 43,
          "qda_publish": "2016-11-01",
          "qda_declaration": "2016-10-14",
          "qct_max_expires": "2015-10-31",
          "qct_current_status": "not-qualified",
          "qda_designation": "2016-10-14",
          "expires": "2021-10-14",
          "incident_description": "Hurricane Insane",
          "hz_type": "qct_qda"
        },
        {
          "gid": 77,
          "county_fips": "45025",
          "tract_fips": "45025950800",
          "county": "McBee",
          "state": "SC",
          "qda_id": 43,
          "qda_publish": "2017-01-01",
          "qda_declaration": "2016-12-25",
          "qct_max_expires": "2015-10-31",
          "qct_current_status": "not-qualified",
          "qda_designation": "2016-12-25",
          "expires": "2021-12-25",
          "incident_description": "Hurricane Insane",
          "hz_type": "qct_qda"
        }
      ],
      until_date: "2021-12-25",
      query_date: nil,
      search_q: "McBee, SC 29101, USA",
      search_latlng: nil,
      api_version: 1
    }
  }
}

# rubocop:disable Metrics/BlockLength
RSpec.describe GeocodeController do
  before do
    create_test_data
  end

  (1..2).each do |version|
    describe "Get data from v#{version} of the API" do
      before do
        geocode_response = {
          results: [
            formatted_address: test_queries[:qct][:response][:formatted_address],
            geometry: {
              location: {
                lat: test_queries[:qct][:lat],
                lng: test_queries[:qct][:lng]
              }
            }
          ],
          status: "OK"
        }
        Excon.stub({host: "maps.googleapis.com"}, status: 200, body: geocode_response.to_json)
        get search_url, params: {q: test_queries[:qct][:query]}, headers: headers_arg(version)
      end
      it 'will include the API version in the response' do
        expect(version).to eq(json[:api_version])
      end
    end
  end

  describe 'GET #search without any query or location' do
    before do
      get search_url, params: {message: 'Search for what?'}
    end
    it 'will result in an error' do
      expect(response.status).to be_between(400, 500)
    end
    it 'will return the status INVALID_REQUEST' do
      expect(json[:status]).to eq('INVALID_REQUEST')
    end
  end

  # tests for address query
  describe 'GET #search with a query' do
    context 'when given a empty query' do
      before do
        get search_url, params: {q: ""}
      end
      it 'will result in an error' do
        expect(response.status).to be_between(400, 500)
      end
      it 'will return the status INVALID_REQUEST' do
        expect(json[:status]).to eq('INVALID_REQUEST')
      end
    end

    # map over each hash in test_queries and run this templated test
    test_queries.map do |hztype, tquery|
      context 'Given an address ' + tquery[:context] do
        before do
          # Excon.stub({}, body: tquery[:response].to_json)
          geocode_response = {
            results: [
              formatted_address: tquery[:response][:formatted_address],
              geometry: {
                location: {
                  lat: tquery[:lat],
                  lng: tquery[:lng]
                }
              }
            ],
            status: "OK"
          }
          Excon.stub({host: "maps.googleapis.com"}, status: 200, body: geocode_response.to_json)
          get search_url, params: {q: tquery[:query]}
        end

        after do
          Excon.stubs.clear
        end

        it "#{hztype} contains the correct fields" do
          json[:hubzone].each do |hz|
            required_fields[hz["hz_type"].to_sym].each { |req| expect(hz.keys.include?(req)).to be true }
          end
        end

        it 'will succeed' do
          expect(response.status).to eql(tquery[:http_status])
        end
        it 'will have a status code' do
          expect(json[:status]).to eql('OK')
        end
        it 'will include a query search value' do
          expect(json[:search_q]).not_to be_empty
        end
        it 'will not include the latlng search value' do
          expect(json[:search_latlng]).to be_nil
        end
        it 'will contain the correct formatted address' do
          expect(json[:formatted_address]).to eql(tquery[:results_address])
        end
        it "will have #{tquery[:designations].size} designation(s)" do
          expect(json[:hubzone].size).to eql(tquery[:designations].size)
        end
        it "will have #{tquery[:designations].join(', ')} designation(s)" do
          hz_types = json[:hubzone].map { |hz| hz['hz_type'] }
          expect(hz_types.sort).to eql(tquery[:designations].sort)
        end
        it "will have a calculated expiration date" do
          expect(json[:until_date]).to eq(tquery[:until_date])
        end
      end
    end
  end

  # tests for latlng
  describe 'GET #search with a lat, lng location' do
    context 'when given an empty latlng' do
      before do
        get search_url, params: {latlng: ""}
      end
      it 'will result in an error' do
        expect(response.status).to be(400)
      end
      it 'will return the status INVALID_REQUEST' do
        expect(json[:status]).to eq('INVALID_REQUEST')
      end
    end

    context 'when given an incomplete location' do
      before do
        get search_url, params: {latlng: '123'}
      end
      it 'will result in an error' do
        expect(response.status).to be(400)
      end
      it 'will return the status INVALID_REQUEST' do
        expect(json[:status]).to eq('INVALID_REQUEST')
      end
    end

    context 'when given a mal-formed location' do
      before do
        get search_url, params: {latlng: 'abc.def,-ghi.jkl'}
      end
      it 'will result in an error' do
        expect(response.status).to be(400)
      end
      it 'will return the status INVALID_REQUEST' do
        expect(json[:status]).to eq('INVALID_REQUEST')
      end
    end

    # map over each hash in test_queries and run this templated test
    test_queries.map do |_hztype, tquery|
      context 'Given an lat,lng ' + tquery[:context] do
        before do
          latlng = "#{tquery[:lat]},#{tquery[:lng]}"
          Excon.stub({}, body: tquery[:response].to_json)
          get search_url, params: {latlng: latlng}
        end
        it 'will succeed' do
          expect(response.status).to eql(tquery[:http_status])
        end
        it 'will include the latlng search value' do
          expect(json[:search_latlng]).not_to be_empty
        end
        it 'will not include a query search value' do
          expect(json[:search_q]).to be_nil
        end
        it "will have #{tquery[:designations].size} designation(s)" do
          expect(json[:hubzone].size).to eql(tquery[:designations].size)
        end
        it "will have #{tquery[:designations].join(', ')} designation(s)" do
          hz_types = json[:hubzone].map { |hz| hz['hz_type'] }
          expect(hz_types.sort).to eql(tquery[:designations].sort)
        end
        it "will have a calculated expiration date" do
          expect(json[:until_date]).to eq(tquery[:until_date])
        end
      end
    end

    # rubocop:disable RSpec/NestedGroups
    context 'when given a valid latlng and a blank q' do
      let(:tquery) { test_queries[:qct] }
      let(:latlng) { '39.2888915,-76.6069962' }
      let(:qquery) { 'reset this in context' }

      before do
        latlng = "#{tquery[:lat]},#{tquery[:lng]}"
        Excon.stub({}, body: tquery[:response].to_json)
        get search_url, params: {latlng: latlng, q: qquery}
      end

      context 'with q == nil' do
        let(:qquery) { nil }

        it 'will succeed' do
          expect(response.status).to eql(tquery[:http_status])
        end
      end
      context 'with q == ""' do
        let(:qquery) { "" }

        it 'will succeed' do
          expect(response.status).to eql(tquery[:http_status])
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups
  end
end
# rubocop:enable Metrics/BlockLength
