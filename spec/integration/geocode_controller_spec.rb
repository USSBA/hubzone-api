require 'rails_helper'

test_query = {
  empty: '',
  qct: '8 Market Place Baltimore MD 21202',
  brac_base: 'forrestal dr, ceiba',
  brac_qct: 'amy, ar',
  qct_not_brac: 'chidester, ar',
  navajo: 'navajo',
  indian_lands: '2424 S. Country Club Road, El Reno, OK 73036',
  roosevelt: 'roosevelt roads, pr'
}
test_query_results = {
  empty: '',
  qct: '8 Market Pl, Baltimore, MD 21202, USA',
  brac_base: 'Forrestal Dr, Ceiba, 00735, Puerto Rico',
  brac_qct: 'Amy, AR 71701, USA',
  qct_not_brac: 'Chidester, AR 71726, USA',
  navajo: 'Navajo, NM 87328, USA',
  indian_lands: '2424 S Country Club Rd, El Reno, OK 73036, USA',
  roosevelt: 'Roosevelt Roads, Ceiba, Puerto Rico'
}
test_latlng = {
  empty: '',
  qct: '39.2888915,-76.6069962',
  brac_base: '18.240392,-65.62385970000001',
  brac_qct: '33.7320525,-92.8154404',
  qct_not_brac: '33.7023315,-93.02044370000002',
  navajo: '35.9000121,-109.0339832',
  indian_lands: '35.5112912,-97.9732157',
  roosevelt: '18.237248,-65.6480292'
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

  describe 'GET #search with a query' do
    context 'when given a empty query' do
      before do
        get search_url, params: {q: test_query[:empty]},
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

    context 'given an address in a QCT in baltimore' do
      before do
        get search_url, params: {q: test_query[:qct]},
                        headers: {'Content-Type' => 'application/json'}
      end
      it 'should succeed' do
        expect(response).to have_http_status(:ok)
      end
      it 'should contain the correct formatted address' do
        body = JSON.parse response.body
        expect(body['formatted_address']).to eql(test_query_results[:qct])
      end
      it 'should have one designation' do
        body = JSON.parse response.body
        expect(body['hubzone'].size).to eql(1)
      end
      it 'should have one QCT designation' do
        body = JSON.parse response.body
        expect(body['hubzone'][0]['hz_type']).to eql('qct')
      end
    end

    context 'given an address in a BRAC base in Puerto Rico' do
      before do
        get search_url, params: {q: test_query[:brac_base]},
                        headers: {'Content-Type' => 'application/json'}
      end
      it 'should succeed' do
        expect(response).to have_http_status(:ok)
      end
      it 'should contain the correct formatted address' do
        body = JSON.parse response.body
        expect(body['formatted_address']).to eql(test_query_results[:brac_base])
      end
      it 'should have one designation' do
        body = JSON.parse response.body
        expect(body['hubzone'].size).to eql(1)
      end
      it 'should have one BRAC designation' do
        body = JSON.parse response.body
        expect(body['hubzone'][0]['hz_type']).to eql('brac')
      end
    end

    context 'given an address in a QCT that is BRAC designated' do
      before do
        get search_url, params: {q: test_query[:brac_qct]},
                        headers: {'Content-Type' => 'application/json'}
      end
      it 'should succeed' do
        expect(response).to have_http_status(:ok)
      end
      it 'should contain the correct formatted address' do
        body = JSON.parse response.body
        expect(body['formatted_address']).to eql(test_query_results[:brac_qct])
      end
      it 'should have one designation' do
        body = JSON.parse response.body
        expect(body['hubzone'].size).to eql(1)
      end
      it 'should have one BRAC designation' do
        body = JSON.parse response.body
        expect(body['hubzone'][0]['hz_type']).to eql('brac')
      end
    end

    context 'given an address in a QCT that is near a BRAC, but is QCT designated' do
      before do
        get search_url, params: {q: test_query[:qct_not_brac]},
                        headers: {'Content-Type' => 'application/json'}
      end
      it 'should succeed' do
        expect(response).to have_http_status(:ok)
      end
      it 'should contain the correct formatted address' do
        body = JSON.parse response.body
        expect(body['formatted_address']).to eql(test_query_results[:qct_not_brac])
      end
      it 'should have one designation' do
        body = JSON.parse response.body
        expect(body['hubzone'].size).to eql(1)
      end
      it 'should have one QCT designation' do
        body = JSON.parse response.body
        expect(body['hubzone'][0]['hz_type']).to eql('qct')
      end
    end

    context 'given an address in an Indian Lands hubzone' do
      before do
        get search_url, params: {q: test_query[:indian_lands]},
                        headers: {'Content-Type' => 'application/json'}
      end
      it 'should succeed' do
        expect(response).to have_http_status(:ok)
      end
      it 'should contain the correct formatted address' do
        body = JSON.parse response.body
        expect(body['formatted_address']).to eql(test_query_results[:indian_lands])
      end
      it 'should have one designation' do
        body = JSON.parse response.body
        expect(body['hubzone'].size).to eql(1)
      end
      it 'should have one indian lands designation' do
        body = JSON.parse response.body
        expect(body['hubzone'][0]['hz_type']).to eql('indian_lands')
      end
    end

    context 'given a search for navajo' do
      before do
        get search_url, params: {q: test_query[:navajo]},
                        headers: {'Content-Type' => 'application/json'}
      end
      it 'should succeed' do
        expect(response).to have_http_status(:ok)
      end
      it 'should contain the correct formatted address' do
        body = JSON.parse response.body
        expect(body['formatted_address']).to eql(test_query_results[:navajo])
      end
      it 'should have one designation' do
        body = JSON.parse response.body
        expect(body['hubzone'].size).to eql(1)
      end
      it 'should have one indian lands designation' do
        body = JSON.parse response.body
        expect(body['hubzone'][0]['hz_type']).to eql('indian_lands')
      end
    end

    context 'given a search on a location in a BRAC, in a CT that is only BRAC designated' do
      before do
        get search_url, params: {q: test_query[:roosevelt]},
                        headers: {'Content-Type' => 'application/json'}
      end
      it 'should succeed' do
        expect(response).to have_http_status(:ok)
      end
      it 'should contain the correct formatted address' do
        body = JSON.parse response.body
        expect(body['formatted_address']).to eql(test_query_results[:roosevelt])
      end
      it 'should have one designations' do
        body = JSON.parse response.body
        expect(body['hubzone'].size).to eql(1)
      end
      it 'should have one BRAC designation' do
        body = JSON.parse response.body
        expect(body['hubzone'][0]['hz_type']).to eql('brac')
      end
    end
  end

  describe 'GET #search with a location' do
    context 'when given an empty latlng' do
      before do
        get search_url, params: {latlng: test_latlng[:empty]},
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

    context 'given a location in a QCT in baltimore' do
      before do
        get search_url, params: {latlng: test_latlng[:qct]},
                        headers: {'Content-Type' => 'application/json'}
      end
      it 'should succeed' do
        expect(response).to have_http_status(:ok)
      end
      it 'should have one designation' do
        body = JSON.parse response.body
        expect(body['hubzone'].size).to eql(1)
      end
      it 'should have one QCT designation' do
        body = JSON.parse response.body
        expect(body['hubzone'][0]['hz_type']).to eql('qct')
      end
    end

    context 'given an location in a BRAC base in Puerto Rico' do
      before do
        get search_url, params: {latlng: test_latlng[:brac_base]},
                        headers: {'Content-Type' => 'application/json'}
      end
      it 'should succeed' do
        expect(response).to have_http_status(:ok)
      end
      it 'should have one designation' do
        body = JSON.parse response.body
        expect(body['hubzone'].size).to eql(1)
      end
      it 'should have one BRAC designation' do
        body = JSON.parse response.body
        expect(body['hubzone'][0]['hz_type']).to eql('brac')
      end
    end

    context 'given an location in a QCT that is BRAC designated' do
      before do
        get search_url, params: {latlng: test_latlng[:brac_qct]},
                        headers: {'Content-Type' => 'application/json'}
      end
      it 'should succeed' do
        expect(response).to have_http_status(:ok)
      end
      it 'should have one designation' do
        body = JSON.parse response.body
        expect(body['hubzone'].size).to eql(1)
      end
      it 'should have one BRAC designation' do
        body = JSON.parse response.body
        expect(body['hubzone'][0]['hz_type']).to eql('brac')
      end
    end

    context 'given an location in a QCT that is near a BRAC, but is QCT designated' do
      before do
        get search_url, params: {latlng: test_latlng[:brac_qct]},
                        headers: {'Content-Type' => 'application/json'}
      end
      it 'should succeed' do
        expect(response).to have_http_status(:ok)
      end
      it 'should have one designation' do
        body = JSON.parse response.body
        expect(body['hubzone'].size).to eql(1)
      end
      it 'should have one QCT designation' do
        body = JSON.parse response.body
        expect(body['hubzone'][0]['hz_type']).to eql('qct')
      end
    end

    context 'given an location in an Indian Lands hubzone' do
      before do
        get search_url, params: {latlng: test_latlng[:indian_lands]},
                        headers: {'Content-Type' => 'application/json'}
      end
      it 'should succeed' do
        expect(response).to have_http_status(:ok)
      end
      it 'should have one designation' do
        body = JSON.parse response.body
        expect(body['hubzone'].size).to eql(1)
      end
      it 'should have one indian lands designation' do
        body = JSON.parse response.body
        expect(body['hubzone'][0]['hz_type']).to eql('indian_lands')
      end
    end

    context 'given a search for navajo' do
      before do
        get search_url, params: {latlng: test_latlng[:navajo]},
                        headers: {'Content-Type' => 'application/json'}
      end
      it 'should succeed' do
        expect(response).to have_http_status(:ok)
      end
      it 'should have one designation' do
        body = JSON.parse response.body
        expect(body['hubzone'].size).to eql(1)
      end
      it 'should have one indian lands designation' do
        body = JSON.parse response.body
        expect(body['hubzone'][0]['hz_type']).to eql('indian_lands')
      end
    end

    context 'given a search on a location in a BRAC, in a CT that is only BRAC designated' do
      before do
        get search_url, params: {latlng: test_latlng[:roosevelt]},
                        headers: {'Content-Type' => 'application/json'}
      end
      it 'should succeed' do
        expect(response).to have_http_status(:ok)
      end
      it 'should have one designations' do
        body = JSON.parse response.body
        expect(body['hubzone'].size).to eql(1)
      end
      it 'should have one BRAC designation' do
        body = JSON.parse response.body
        hz_types = body['hubzone'].map { |hz| hz['hz_type'] }
        expect(hz_types).to include('brac')
      end
    end
  end
end
