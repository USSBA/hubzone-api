require 'rails_helper'
require 'helpers/test_data_helper'

RSpec.configure do |c|
  c.include TestDataHelper
end

def search_url
  api_search_url
end

def json
  JSON.parse(response.body).symbolize_keys
end

def parameters(p, version = 1)
  { params: p, headers: {'Accept' => "application/sba.hubzone-api.v#{version}"} }
end

required_fields = {
  qct_e: %w[tract_fips county state],
  qct_r: %w[tract_fips county state],
  qnmc_e: %w[county_fips county state],
  qnmc_r: %w[county_fips county state],
  indian_lands: %w[name census type class gnis],
  brac: %w[brac_sba_name fac_type effective],
  qct_brac: %w[brac_sba_name fac_type effective tract_fips county state],
  qnmc_brac: %w[brac_sba_name fac_type effective county_fips county state],
  qct_qda: %w[incident_description qda_declaration qda_designation qda_publish tract_fips county state],
  qnmc_qda: %w[incident_description qda_declaration qda_designation qda_publish county_fips county state]
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
  qct_r: {
    context: 'in a redesignated QCT in baltimore',
    query: 'Holgate Dr, Essex, MD 21221, USA',
    latlng: '39.30428,-76.44791',
    http_status: 200,
    results_address: 'Holgate Dr, Essex, MD 21221, USA',
    designations: %w[qct_r],
    until_date: '2019-10-15'
  },
  brac_base: {
    context: 'in a BRAC base in Puerto Rico',
    query: 'forrestal dr, ceiba',
    latlng: '18.240392,-65.62385970000001',
    http_status: 200,
    results_address: 'Forrestal Dr, Ceiba, 00735, Puerto Rico',
    designations: %w[brac qct_brac],
    until_date: '2020-09-15'
  },
  brac_qct: {
    context: 'in a QCT that is BRAC designated',
    query: 'amy, ar',
    latlng: '33.7320525,-92.8154404',
    http_status: 200,
    results_address: 'Amy, AR 71701, USA',
    designations: %w[qct_brac], # not added to test data: qnmc_brac)
    until_date: '2021-11-05'
  },
  qct_not_brac: {
    context: 'in a QCT that is near a BRAC, but is QCT designated',
    query: 'chidester, ar',
    latlng: '33.7023315,-93.02044370000002',
    http_status: 200,
    results_address: 'Chidester, AR 71726, USA',
    designations: %w[qct_e], # not added to test data: qnmc_brac)
    until_date: nil
  },
  brac_qnmc: {
    context: 'in a QNMC that is BRAC designated',
    query: 'mabie, wv',
    latlng: '38.8764985,-79.9853181',
    http_status: 200,
    results_address: 'Mabie, WV 26257, USA',
    designations: %w[qnmc_brac], # not added to test data: qct_b),
    until_date: '2020-04-16'
  },
  qnmc_not_brac: {
    context: 'in a QNMC that is near a BRAC, but is QNMC designated',
    query: 'buckeye, wv',
    latlng: '38.1902273,-80.1360778',
    http_status: 200,
    results_address: 'Buckeye, WV, USA',
    designations: %w[qnmc_a],
    until_date: nil
  },
  indian_lands: {
    context: 'in an Indian Lands hubzone',
    query: '2424 S. Country Club Road, El Reno, OK 73036',
    latlng: '35.5112912,-97.9732157',
    http_status: 200,
    results_address: '2424 S Country Club Rd, El Reno, OK 73036, USA',
    designations: %w[indian_lands],
    until_date: nil
  },
  navajo: {
    context: 'of navajo',
    query: 'navajo',
    #latlng: '35.9000121,-109.0339832',
    latlng: '36.0672173,-109.1880047',
    http_status: 200,
    results_address: 'Navajo Nation Reservation, AZ, USA',
    designations: %w[indian_lands qct_e qnmc_b],
    until_date: nil
  },
  roosevelt: {
    context: 'for a location in a BRAC, in a CT that is only BRAC designated',
    query: 'roosevelt roads, pr',
    latlng: '18.237248,-65.6480292',
    http_status: 200,
    results_address: 'Roosevelt Roads, Ceiba, Puerto Rico',
    designations: %w[brac qct_brac],
    until_date: '2020-09-15'
  },
  stilwell: {
    context: 'of stilwell, ok',
    query: 'stilwell, ok',
    latlng: '35.8185419,-94.6675625',
    http_status: 200,
    results_address: 'Stilwell, OK 74960, USA',
    designations: %w[qct_e qnmc_a indian_lands],
    until_date: nil
  },
  redesignated_qnmc_and_qct: {
    context: 'of pine view, TN',
    query: 'pine view tn',
    latlng: '35.73027,-87.93413',
    http_status: 200,
    results_address: 'Pine View, TN 37096, USA',
    designations: %w[qct_r qnmc_r],
    until_date: '2018-07-31'
  },
  redesignated_qct_and_qnmc_brac: {
    context: 'of warden washington',
    query: '121 ash st warden wa',
    latlng: '46.96861,-119.03905',
    http_status: 200,
    results_address: '121 S Ash Ave, Warden, WA 98857, USA',
    designations: %w[qct_r qnmc_brac],
    until_date: '2020-12-31'
  },
  qnmc_qda: {
    context: 'of rockyhock nc',
    query: 'Rockyhock, NC, USA',
    latlng: '36.18011,-76.69318',
    http_status: 200,
    results_address: 'Rockyhock, NC 27932, USA',
    designations: %w[qnmc_qda],
    until_date: '2021-10-10'
  },
  qct_qda: {
    context: 'of mcbee SC',
    query: 'mcbee SC',
    latlng: '34.4690418,-80.2559033',
    http_status: 200,
    results_address: 'McBee, SC 29101, USA',
    designations: %w[qct_qda],
    until_date: '2021-10-14'
  }
}

# rubocop:disable Metrics/BlockLength
RSpec.describe GeocodeController, vcr: true, type: :request do
  before do
    create_test_data
  end

  (1..2).each do |version|
    describe "Get data from v#{version} of the API" do
      before do
        get search_url, parameters({q: test_queries[:qct][:query]}, version)
      end
      it 'should include the API version in the response' do
        expect(version).to eq(json[:api_version])
      end
    end
  end

  describe 'GET #search without any query or location' do
    before do
      get search_url, parameters(message: 'Search for what?')
    end
    it 'should result in an error' do
      expect(400...500).to cover(response.status)
    end
    it 'should return the status INVALID_REQUEST' do
      expect(json[:status]).to eq('INVALID_REQUEST')
    end
  end

  # tests for address query
  describe 'GET #search with a query' do
    context 'when given a empty query' do
      before do
        get search_url, parameters(q: "")
      end
      it 'should result in an error' do
        expect(400...500).to cover(response.status)
      end
      it 'should return the status INVALID_REQUEST' do
        expect(json[:status]).to eq('INVALID_REQUEST')
      end
    end

    # map over each hash in test_queries and run this templated test
    test_queries.map do |_hztype, tquery|
      context 'Given an address ' + tquery[:context] do
        before do
          get search_url, parameters(q: tquery[:query])
        end

        it "#{_hztype} contains the correct fields" do
          json[:hubzone].each do |hz|
            req_fields = required_fields[hz["hz_type"].to_sym]
            field_diff =  (req_fields - hz.keys)
            puts hz["hz_type"], field_diff
            expect(field_diff.empty?).to be(true)
          end
        end

        it 'should succeed' do
          expect(response.status).to eql(tquery[:http_status])
        end
        it 'should contain the correct formatted address' do
          expect(json[:formatted_address]).to eql(tquery[:results_address])
        end
        it "should have #{tquery[:designations].size} designation(s)" do
          expect(json[:hubzone].size).to eql(tquery[:designations].size)
        end
        it "should have #{tquery[:designations].join(', ')} designation(s)" do
          hz_types = json[:hubzone].map { |hz| hz['hz_type'] }
          expect(hz_types.sort).to eql(tquery[:designations].sort)
        end
        it "should have a calculated expiration date" do
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
      it 'should result in an error' do
        expect(response.status).to eql(400)
      end
      it 'should return the status INVALID_REQUEST' do
        expect(json[:status]).to eq('INVALID_REQUEST')
      end
    end

    context 'when given an incomplete location' do
      before do
        get search_url, parameters(latlng: '123')
      end
      it 'should result in an error' do
        expect(response.status).to eql(400)
      end
      it 'should return the status INVALID_REQUEST' do
        expect(json[:status]).to eq('INVALID_REQUEST')
      end
    end

    context 'when given a mal-formed location' do
      before do
        get search_url, parameters(latlng: 'abc.def,-ghi.jkl')
      end
      it 'should result in an error' do
        expect(response.status).to eql(400)
      end
      it 'should return the status INVALID_REQUEST' do
        expect(json[:status]).to eq('INVALID_REQUEST')
      end
    end

    # map over each hash in test_queries and run this templated test
    test_queries.map do |_hztype, tquery|
      context 'Given an lat,lng ' + tquery[:context] do
        before do
          get search_url, parameters(latlng: tquery[:latlng])
        end
        it 'should succeed' do
          expect(response.status).to eql(tquery[:http_status])
        end
        it "should have #{tquery[:designations].size} designation(s)" do
          expect(json[:hubzone].size).to eql(tquery[:designations].size)
        end
        it "should have #{tquery[:designations].join(', ')} designation(s)" do
          hz_types = json[:hubzone].map { |hz| hz['hz_type'] }
          expect(hz_types.sort).to eql(tquery[:designations].sort)
        end
        it "should have a calculated expiration date" do
          expect(json[:until_date]).to eq(tquery[:until_date])
        end
      end
    end
  end
end
