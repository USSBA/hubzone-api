require 'rails_helper'

test_data = {
  empty_request: '',
  good_request: '8 Market Place Baltimore MD 21202',
  garbage_request: '\asdfaewrves5hw4aergqqv3 \!@%#',
  blank_request: ' '
}

# rubocop:disable Layout/CommentIndentation, Metrics/BlockLength
describe Geocoder, type: :model do
  describe '.search' do
    context "when given a empty request" do
      let(:response) { Geocoder.search(test_data[:empty_request]) }

      it "will result in an error" do
        expect(response.status).to be_between(400, 500)
      end
      it "will return a status of INVALID_REQUEST" do
        body_json = JSON.parse(response.body)
        expect(body_json['status']).to eq('INVALID_REQUEST')
      end
    end

    context "when given a good request" do
      let(:response) { Geocoder.search(test_data[:good_request]) }

      it "will succeed" do
        expect(response.status).to eql(Rack::Utils::SYMBOL_TO_STATUS_CODE[:ok])
      end
      it "will return a status of OK" do
        body_json = JSON.parse(response.body)
        expect(body_json['status']).to eq('OK')
      end
    end

    context "when given a garbage request" do
      let(:response) { Geocoder.search(test_data[:garbage_request]) }

      it "will succeed" do
        expect(response.status).to be_between(200, 300)
      end
      it "will return a status of ZERO_RESULTS" do
        body_json = JSON.parse(response.body)
        expect(body_json['status']).to eq('ZERO_RESULTS')
      end
    end

    context "when given a blank request" do
      let(:response) { Geocoder.search(test_data[:blank_request]) }

      it "will succeed" do
        expect(response.status).to be_between(200, 300)
      end
      it "will return a status of ZERO_RESULTS" do
        body_json = JSON.parse(response.body)
        expect(body_json['status']).to eq('ZERO_RESULTS')
      end
    end

#    context "when over the quota limit" do
#      let(:response) {Geocoder.search(test_data[:good_request])}
#      it "returns error" do
#        skip "skipped because we cant really test this response"
#        expect(400...500).to cover(response.status)
#      end
#      it "returns OVER_QUOTA_LIMIT" do
#        skip "skipped because we cant really test this response"
#        body_json = JSON.parse(response.body)
#        expect(body_json['status']).to eq('OVER_QUOTA_LIMIT')
#      end
#    end

    context "when the API key is bad" do
      let(:api_key) { MAP_CONFIG[:google_api_key] }
      let(:response) { Geocoder.search(test_data[:good_request]) }

      before { MAP_CONFIG[:google_api_key] = "SyBsR78bM2H5vM" }

      it "will 'succeed' because Google is crazy" do
        expect(response.status).to eql(Rack::Utils::SYMBOL_TO_STATUS_CODE[:ok])
      end
      it "will return a status of REQUEST_DENIED" do
        #skip "skipped because we cant really test this response"
        body_json = JSON.parse(response.body)
        expect(body_json['status']).to eq('REQUEST_DENIED')
      end
      after { MAP_CONFIG[:google_api_key] = api_key }
    end

#    context "when an unknown error occurs" do
#      let(:response) {Geocoder.search(test_data[:good_request])}
#      it "returns error" do
#        skip "skipped because we cant really test this response"
#        expect(400...500).to cover(response.status)
#      end
#      it "returns UNKNOWN_ERROR" do
#        skip "skipped because we cant really test this response"
#        body_json = JSON.parse(response.body)
#        expect(body_json['status']).to eq('UNKNOWN_ERROR')
#      end
#    end
  end
end
