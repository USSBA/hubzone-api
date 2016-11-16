require 'rails_helper'

test_data = {
  empty_request: '',
  qct_request: '8 Market Place Baltimore MD 21202',
  brac_request: 'forrestal dr, ceiba',
  navajo_request: 'navajo',
  indian_lands_request: '2424 S. Country Club Road, El Reno, OK 73036'
}
test_results = {
  empty_request: '',
  qct_request: '8 Market Pl, Baltimore, MD 21202, USA',
  brac_request: 'Forrestal Dr, Ceiba, 00735, Puerto Rico',
  navajo_request: 'Navajo, NM 87328, USA',
  indian_lands_request: '2424 S Country Club Rd, El Reno, OK 73036, USA'
}

RSpec.describe GeocodeController, type: :request do

  describe 'GET #search' do
    context 'when given a empty request' do
      before do
        get search_url, {params: {q: test_data[:empty_request]},
                         headers: {'Content-Type' => 'application/json'}}
      end
      it 'should result in an error' do
        expect(400...500).to cover(response.status)
      end
      it 'should return the status INVALID_REQUEST' do
        bodyJson = JSON.parse(response.body)
        expect(bodyJson['status']).to eq('INVALID_REQUEST')
      end
    end

    context 'given a qct request in baltimore' do
      before do
        get search_url, {params: {q: test_data[:qct_request]},
                         headers: {'Content-Type' => 'application/json'}}
      end
      it 'should succeed' do
        expect(response).to have_http_status(:ok)
      end
      it 'should contain the correct formatted address' do
        body = JSON.parse response.body
        expect(body['formatted_address']).to eql(test_results[:qct_request])
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

    context 'given an address in a BRAC in Puerto Rico' do
      before do
        get search_url, {params: {q: test_data[:brac_request]},
                         headers: {'Content-Type' => 'application/json'}}
      end
      it 'should succeed' do
        expect(response).to have_http_status(:ok)
      end
      it 'should contain the correct formatted address' do
        body = JSON.parse response.body
        expect(body['formatted_address']).to eql(test_results[:brac_request])
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

    context 'given a search for an address in an indian lands hubzone' do
      before do
        get search_url, {params: {q: test_data[:indian_lands_request]},
                         headers: {'Content-Type' => 'application/json'}}
      end
      it 'should succeed' do
        expect(response).to have_http_status(:ok)
      end
      it 'should contain the correct formatted address' do
        body = JSON.parse response.body
        expect(body['formatted_address']).to eql(test_results[:indian_lands_request])
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
        get search_url, {params: {q: test_data[:navajo_request]},
                         headers: {'Content-Type' => 'application/json'}}
      end
      it 'should succeed' do
        expect(response).to have_http_status(:ok)
      end
      it 'should contain the correct formatted address' do
        body = JSON.parse response.body
        expect(body['formatted_address']).to eql(test_results[:navajo_request])
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
  end
end
