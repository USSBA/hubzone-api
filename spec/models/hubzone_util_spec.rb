require 'rails_helper'
require 'helpers/test_data_helper'

RSpec.configure do |c|
  c.include TestDataHelper

  # Excon.defaults[:mock] = true
  # Excon.stub({}, {:body => 'Fallback', :status => 200})
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
  #likely_qda: %w[incident_description qda_declaration],
  congressional_district: %w[state namelsad cdsessn]
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
    designations: %w[qnmc_c],
    until_date: nil
  },
  qnmc_ab: {
    context: 'in a QNMC that is qualified by income and unemployment',
    query: 'mcdowell county, wv',
    latlng: '37.3784254787199,-81.6533743864188',
    http_status: 200,
    results_address: 'McDowell County, WV, USA',
    designations: %w[qnmc_ab],
    until_date: nil
  },
  qnmc_ac: {
    context: 'in a QNMC that is qualified by income and dda',
    query: 'Montgomery county, MD',
    latlng: '39.1375983881007,-77.2013015061578',
    http_status: 200,
    results_address: 'Montgomery County, MD, USA',
    designations: %w[qnmc_ac],
    until_date: nil
  },
  qnmc_bc: {
    context: 'in a QNMC that is qualified by unemployment and dda',
    query: 'Las Marias, PR',
    latlng: '18.2369874876476,-66.9834681952306',
    http_status: 200,
    results_address: 'Las Marías, 00685, Puerto Rico',
    designations: %w[qnmc_bc],
    until_date: nil
  },
  qnmc_abc: {
    context: 'in a QNMC that is qualified by income and unemployment and dda',
    query: 'nome, ak',
    latlng: '64.897820896618,-163.953755957951',
    http_status: 200,
    results_address: 'Nome, AK, USA',
    designations: %w[qnmc_abc],
    until_date: nil
  },
  non_qnmc: {
    context: 'Error check: in a county that is not qualfied but got into the db',
    query: 'terrebonne, LA',
    latlng: '29.4301161517758,-90.8647853753743',
    http_status: 200,
    results_address: 'Terrebonne Parish, LA, USA',
    designations: %w[non_qnmc],
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
    latlng: '36.0672173,-109.1880047',
    http_status: 200,
    results_address: 'Navajo Nation Reservation, Utah, USA',
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
    context: 'of mcbee SC where there are two qct_qda designations',
    query: 'mcbee SC',
    latlng: '34.4690418,-80.2559033',
    http_status: 200,
    results_address: 'McBee, SC 29101, USA',
    designations: %w[qct_qda qct_qda],
    until_date: '2021-12-25'
  }
}

# likely qda mock

#test_likely_qda_queries = {
#  likely_qda: {
#    context: 'a likely_qda in florida',
#    query: 'fort lauderdale, fl',
#    latlng: '26.118002,-80.139390',
#    http_status: 200,
#    results_address: 'Fort Lauderdale, FL, USA',
#    designations: nil,
#    until_date: nil
#  }
#}

# mocks for other information layers
test_other_information_queries = {
  congressional_district: {
    context: 'something in district 9',
    query: 'Forestdale-Pocasset-Sandwich Rd, bourne MA',
    latlng: '41.6941840911004, -70.4814792891057',
    http_status: 200,
    results_address: 'Forestdale-Pocasset-Sandwich Rd, Bourne, MA 02532, USA',
    designations: nil,
    until_date: nil
  }
}

# rubocop:disable Metrics/BlockLength
RSpec.describe HubzoneUtil do
  before do
    create_test_data
    Excon.defaults[:mock] = true
    Excon.stub({}, body: 'Fallback', status: 200)
  end

  after do
    Excon.stubs.clear
    Excon.defaults[:mock] = false
  end

  context "with a search without any query or location" do
    let(:params) { { message: "something" } }

    it "will result in an error" do
      results = described_class.search params
      expect(results[:http_status]).to match(400)
    end

    it "will return an invalid request message" do
      results = described_class.search params
      expect(results[:status]).to match("INVALID_REQUEST")
    end
  end

  context "with a search with an empty query" do
    let(:params) { { q: "" } }

    it "will result in an error" do
      results = described_class.search params
      expect(results[:http_status]).to match(400)
    end

    it "will return an invalid request message" do
      results = described_class.search params
      expect(results[:status]).to match("INVALID_REQUEST")
    end
  end

  # response in an area with likely qda has the correct other_information
  #  test_likely_qda_queries.map do |_likely, tquery|
  #    context 'Given a address in ' + tquery[:context] do
  #      let!(:params) { { q: tquery[:query] } }
  #      let(:response) { described_class.search params }

  #      before do
  #        lat = tquery[:latlng].split(',')[0].to_f
  #        lng = tquery[:latlng].split(',')[1].to_f
  #        geocode_response = {"results" => [{"formatted_address" => tquery[:results_address], "geometry" => {"location" => {"lat" => lat, "lng" => lng}}}], "status" => "OK"}

  #        Excon.stub({}, status: 200, body: geocode_response.to_json)
  #      end

  #      it 'will include the other_information content' do
  #        expect(response[:other_information][:alerts][:likely_qda_designations]).not_to be_nil
  #      end

  #      it 'will contain the correct fields' do
  #        likely_qda_designations = response[:other_information][:alerts][:likely_qda_designations]
  #        likely_qda_designations.each do |qda|
  #          all_fields = required_fields[:likely_qda].map { |req| qda.keys.include?(req) }
  #          expect(all_fields.all?).to be(true)
  #        end
  #      end
  #    end
  #  end

  # test the response body of a congressional districts request
  test_other_information_queries.map do |other_type, tquery|
    context "Given a address in #{tquery[:context]}" do
      let!(:params) { { q: tquery[:query] } }
      let(:response) { described_class.search params }

      before do
        lat = tquery[:latlng].split(',')[0].to_f
        lng = tquery[:latlng].split(',')[1].to_f
        geocode_response = {"results" => [{"formatted_address" => tquery[:results_address], "geometry" => {"location" => {"lat" => lat, "lng" => lng}}}], "status" => "OK"}

        Excon.stub({}, status: 200, body: geocode_response.to_json)
      end

      it 'will include the other_information content' do
        expect(response[:other_information][other_type]).not_to be_nil
      end

      it 'will contain the correct fields' do
        designations = response[:other_information][other_type]
        designations.each do |other|
          all_fields = required_fields[other_type].map { |req| other.keys.include?(req) }
          expect(all_fields.all?).to be(true)
        end
      end
    end
  end

  # map over each hash in test_queries and run this templated test
  test_queries.map do |hztype, tquery|
    context "Given an address #{tquery[:context]}" do
      let!(:params) { { q: tquery[:query] } }
      let(:response) { described_class.search params }

      before do
        lat = tquery[:latlng].split(',')[0].to_f
        lng = tquery[:latlng].split(',')[1].to_f
        geocode_response = {"results" => [{"formatted_address" => tquery[:results_address], "geometry" => {"location" => {"lat" => lat, "lng" => lng}}}], "status" => "OK"}

        Excon.stub({}, status: 200, body: geocode_response.to_json)
      end

      it "#{hztype} contains the correct fields" do
        response[:hubzone].each do |hz|
          all_fields = required_fields[hz["hz_type"].to_sym].each { |req| hz.keys.include?(req) }
          expect(all_fields.all?).to be(true)
        end
      end

      it 'will include a query search value' do
        expect(response[:search_q]).not_to be_empty
      end

      it 'will not include the latlng search value' do
        expect(response[:search_latlng]).to be_nil
      end

      it 'will contain the correct formatted address' do
        expect(response["formatted_address"]).to eql(tquery[:results_address])
      end

      it "will have #{tquery[:designations].size} designation(s)" do
        expect(response[:hubzone].size).to eql(tquery[:designations].size)
      end

      it "will have #{tquery[:designations].join(', ')} designation(s)" do
        hz_types = response[:hubzone].map { |hz| hz['hz_type'] }
        expect(hz_types.sort).to eql(tquery[:designations].sort)
      end

      it "will have a calculated expiration date" do
        response[:until_date] = response[:until_date].to_s unless response[:until_date].nil?
        expect(response[:until_date]).to eq(tquery[:until_date])
      end
    end
  end

  context 'when given an empty latlng' do
    let!(:params) { { latlng: "" } }
    let(:response) { described_class.search params }

    it 'will result in an error' do
      expect(response[:http_status]).to be(400)
    end

    it 'will return the status INVALID_REQUEST' do
      expect(response[:status]).to eq('INVALID_REQUEST')
    end
  end

  context 'when given an incomplete location' do
    let!(:params) { { latlng: "123" } }
    let(:response) { described_class.search params }

    it 'will result in an error' do
      expect(response[:http_status]).to be(400)
    end

    it 'will return the status INVALID_REQUEST' do
      expect(response[:status]).to eq('INVALID_REQUEST')
    end
  end

  context 'when given a mal-formed location' do
    let!(:params) { { latlng: "abc.def,-ghi.jkl" } }
    let(:response) { described_class.search params }

    it 'will result in an error' do
      expect(response[:http_status]).to be(400)
    end

    it 'will return the status INVALID_REQUEST' do
      expect(response[:status]).to eq('INVALID_REQUEST')
    end
  end

  # map over each hash in test_queries and run this templated test
  test_queries.map do |_hztype, tquery|
    context "Given an lat,lng #{tquery[:context]}" do
      let!(:params) { { latlng: tquery[:latlng] } }
      let(:response) { described_class.search params }

      it 'will include the latlng search value' do
        expect(response[:search_latlng]).not_to be_empty
      end

      it 'will not include a query search value' do
        expect(response[:search_q]).to be_nil
      end

      it "will have #{tquery[:designations].size} designation(s)" do
        expect(response[:hubzone].size).to eql(tquery[:designations].size)
      end

      it "will have #{tquery[:designations].join(', ')} designation(s)" do
        hz_types = response[:hubzone].map { |hz| hz['hz_type'] }
        expect(hz_types.sort).to eql(tquery[:designations].sort)
      end

      it "will have a calculated expiration date" do
        response[:until_date] = response[:until_date].to_s unless response[:until_date].nil?
        expect(response[:until_date]).to eq(tquery[:until_date])
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
