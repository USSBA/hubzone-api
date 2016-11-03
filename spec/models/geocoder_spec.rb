require 'rails_helper'
require 'Geocoder'

testData = { 
  null_request: '',
  good_request: '8 Market Place Baltimore MD 21202',
  garbage_request: 'asdfaewrves5hw4aergqqv3 \!@%#',
  blank_request: ' ',

}

describe Geocoder, type: :model do
  context "when given a null request" do
    let(:response) {Geocoder.search(testData[:null_request])}
    it "returns error" do
      expect(400...500).to cover(response.status)
    end
    it "returns INVALID_REQUEST" do
      bodyJson = JSON.parse(response.body)
      expect(bodyJson['status']).to eq('INVALID_REQUEST')
    end
  end

  context "when given a good request" do
    let(:response) {Geocoder.search(testData[:good_request])}
    it "succeeds" do
      expect(200...300).to cover(response.status)
    end
    it "returns OK" do
      bodyJson = JSON.parse(response.body)
      expect(bodyJson['status']).to eq('OK')
    end
  end

  context "when given a garbage request" do
    let(:response) {Geocoder.search(testData[:garbage_request])}
    it "succeeds" do
      expect(200...300).to cover(response.status)
    end
    it "returns ZERO_RESULTS" do
      bodyJson = JSON.parse(response.body)
      expect(bodyJson['status']).to eq('ZERO_RESULTS')
    end
  end

  context "when given a blank request" do
    let(:response) {Geocoder.search(testData[:blannk_request])}
    it "returns error" do
      expect(400...500).to cover(response.status)
    end
    it "returns INVALID_REQUEST" do
      bodyJson = JSON.parse(response.body)
      expect(bodyJson['status']).to eq('INVALID_REQUEST')
    end
  end

end
