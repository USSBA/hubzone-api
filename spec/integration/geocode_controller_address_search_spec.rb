require 'rails_helper'

test_queries = {
  qct: {
    context: 'in a QCT in baltimore',
    query: '8 Market Place Baltimore MD 21202',
    latlng: '39.2888915,-76.6069962',
    http_status: 200,
    results_address: '8 Market Pl, Baltimore, MD 21202, USA',
    designations: %w(qct_e)
  },
  brac_base: {
    context: 'in a BRAC base in Puerto Rico',
    query: 'forrestal dr, ceiba',
    latlng: '18.240392,-65.62385970000001',
    http_status: 200,
    results_address: 'Forrestal Dr, Ceiba, 00735, Puerto Rico',
    designations: %w(brac qct_b)
  },
  brac_qct: {
    context: 'in a QCT that is BRAC designated',
    query: 'amy, ar',
    latlng: '33.7320525,-92.8154404',
    http_status: 200,
    results_address: 'Amy, AR 71701, USA',
    designations: %w(qct_b)
  },
  qct_not_brac: {
    context: 'in a QCT that is near a BRAC, but is QCT designated',
    query: 'chidester, ar',
    latlng: '33.7023315,-93.02044370000002',
    http_status: 200,
    results_address: 'Chidester, AR 71726, USA',
    designations: %w(qct_e)
  },
  indian_lands: {
    context: 'in an Indian Lands hubzone',
    query: '2424 S. Country Club Road, El Reno, OK 73036',
    latlng: '35.5112912,-97.9732157',
    http_status: 200,
    results_address: '2424 S Country Club Rd, El Reno, OK 73036, USA',
    designations: %w(indian_lands)
  },
  navajo: {
    context: 'of navajo',
    query: 'navajo',
    latlng: '35.9000121,-109.0339832',
    http_status: 200,
    results_address: 'Navajo, NM 87328, USA',
    designations: %w(indian_lands qct_e)
  },
  roosevelt: {
    context: 'for a location in a BRAC, in a CT that is only BRAC designated',
    query: 'roosevelt roads, pr',
    latlng: '18.237248,-65.6480292',
    http_status: 200,
    results_address: 'Roosevelt Roads, Ceiba, Puerto Rico',
    designations: %w(brac qct_b)
  }
}

RSpec.describe GeocodeController, vcr: true, type: :request do

  describe 'GET #search without any query or location' do
    before do
      get search_url, params: {message: 'Search for what?'},
                      headers: {'Content-Type' => 'application/json'}
    end
    it 'should result in an error' do
      expect(400...500).to cover(response.status)
    end
    it 'should return the status INVALID_REQUEST' do
      body_json = JSON.parse(response.body)
      expect(body_json['status']).to eq('INVALID_REQUEST')
    end
  end

  # tests for address query
  describe 'GET #search with a query' do
    context 'when given a empty query' do
      before do
        get search_url, params: {q: ""},
                        headers: {'Content-Type' => 'application/json'}
      end
      it 'should result in an error' do
        expect(400...500).to cover(response.status)
      end
      it 'should return the status INVALID_REQUEST' do
        body_json = JSON.parse(response.body)
        expect(body_json['status']).to eq('INVALID_REQUEST')
      end
    end

    # map over each hash in test_queries and run this templated test
    test_queries.map do |_hztype, tquery|
      context 'Given an address ' + tquery[:context] do
        before do
          get search_url, params: {q: tquery[:query]},
                          headers: {'Content-Type' => 'application/json'}
        end
        it 'should succeed' do
          expect(response.status).to eql(tquery[:http_status])
        end
        it 'should contain the correct formatted address' do
          body = JSON.parse response.body
          expect(body['formatted_address']).to eql(tquery[:results_address])
        end
        it "should have #{tquery[:designations].size} designation(s)" do
          body = JSON.parse response.body
          expect(body['hubzone'].size).to eql(tquery[:designations].size)
        end
        it "should have #{tquery[:designations].join(', ')} designation(s)" do
          body = JSON.parse response.body
          hz_types = body['hubzone'].map { |hz| hz['hz_type'] }
          expect(hz_types.sort).to eql(tquery[:designations].sort)
        end
      end
    end
  end

  # tests for latlng
  describe 'GET #search with a lat, lng location' do
    context 'when given an empty latlng' do
      before do
        get search_url, params: {latlng: ""},
                        headers: {'Content-Type' => 'application/json'}
      end
      it 'should result in an error' do
        expect(response.status).to eql(400)
      end
      it 'should return the status INVALID_REQUEST' do
        body_json = JSON.parse(response.body)
        expect(body_json['status']).to eq('INVALID_REQUEST')
      end
    end
    test_queries.map do |_hztype, tquery|
      context 'Given an lat,lng ' + tquery[:context] do
        before do
          get search_url, params: {latlng: tquery[:latlng]},
                          headers: {'Content-Type' => 'application/json'}
        end
        it 'should succeed' do
          expect(response.status).to eql(tquery[:http_status])
        end
        it "should have #{tquery[:designations].size} designation(s)" do
          body = JSON.parse response.body
          expect(body['hubzone'].size).to eql(tquery[:designations].size)
        end
        it "should have #{tquery[:designations].join(', ')} designation(s)" do
          body = JSON.parse response.body
          hz_types = body['hubzone'].map { |hz| hz['hz_type'] }
          expect(hz_types.sort).to eql(tquery[:designations].sort)
        end
      end
    end
  end
end
