require 'rails_helper'

test_data = {
  empty_request: '',
  good_request: '8 Market Place Baltimore MD 21202',
  navajo_request: 'navajo',
  indian_lands_request: '2424 S. Country Club Road, El Reno, OK 73036'
}
test_results = {
  empty_request: '',
  good_request: '8 Market Pl, Baltimore, MD 21202, USA',
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

    context 'given a good request in baltimore' do
      before do
        get search_url, {params: {q: test_data[:good_request]},
                         headers: {'Content-Type' => 'application/json'}}
      end
      it 'should succeed' do
        expect(response).to have_http_status(:ok)
      end
      it 'should contain the correct formatted address' do
        body = JSON.parse response.body
        expect(body['formatted_address']).to eql(test_results[:good_request])
      end
      it 'should have no indian lands designations' do
        body = JSON.parse response.body
        expect(body['hubzone'].size).to eql(0)
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
      it 'should have one indian lands designation' do
        body = JSON.parse response.body
        expect(body['hubzone'].size).to eql(1)
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
      it 'should have one indian lands designation' do
        body = JSON.parse response.body
        expect(body['hubzone'].size).to eql(1)
      end
    end
  end
end
