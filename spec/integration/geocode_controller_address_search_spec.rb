require 'rails_helper'
require 'helpers/test_data_helper'

RSpec.configure do |c|
  c.include TestDataHelper
end

def search_url
  api_search_url
end

def parameters(p, version = 1)
  { params: p, headers: {'Accept' => "application/sba.hubzone-api.v#{version}"} }
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
  non_qnmc: %w[county_fips county state]
}

test_queries = {
  qct: {
    context: 'in a QCT in baltimore',
    query: '8 Market Place Baltimore MD 21202',
    latlng: '39.2888915,-76.6069962',
    http_status: 200,
    results_address: '8 Market Pl, Baltimore, MD 21202, USA',
    designations: %w[qct_e],
    until_date: nil
  },
  roosevelt: {
    context: 'for a location in a BRAC, in a CT that is only BRAC designated',
    query: 'Roosevelt Roads, Ceiba, Puerto Rico',
    latlng: '18.237248,-65.6480292',
    http_status: 200,
    results_address: 'Roosevelt Roads, Ceiba, Puerto Rico',
    designations: %w[brac qct_brac],
    until_date: '2020-09-15'
  },
  qct_qda: {
    context: 'of mcbee SC where there are two qct_qda designations',
    query: 'McBee, SC 29101, USA',
    latlng: '34.4690418,-80.2559033',
    http_status: 200,
    results_address: 'McBee, SC 29101, USA',
    designations: %w[qct_qda qct_qda],
    until_date: '2021-12-25'
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
        get search_url, parameters({q: test_queries[:qct][:query]}, version)
      end
      it 'will include the API version in the response' do
        expect(version).to eq(json[:api_version])
      end
    end
  end

  describe 'GET #search without any query or location' do
    before do
      get search_url, parameters(message: 'Search for what?')
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
        get search_url, parameters(q: "")
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
          get search_url, parameters(q: tquery[:query])
        end

        it "#{hztype} contains the correct fields" do
          json[:hubzone].each do |hz|
            required_fields[hz["hz_type"].to_sym].each { |req| expect(hz.keys.include?(req)) }
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
        get search_url, parameters(latlng: "")
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
        get search_url, parameters(latlng: '123')
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
        get search_url, parameters(latlng: 'abc.def,-ghi.jkl')
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
          get search_url, parameters(latlng: tquery[:latlng])
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
  end
end
