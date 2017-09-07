require 'rails_helper'
require 'helpers/test_data_helper'

RSpec.configure do |c|
  c.include TestDataHelper
end

RSpec.describe GeocodeController do
  before do
    create_test_data
  end

  describe 'GET #api_search without any query or location' do
    before do
      # get search_url, parameters(message: 'Search for what?')
      get :api_search, params: { message: 'Search for what?' }
    end
    it 'will result in an error' do
      expect(response.status).to be_between(400, 500)
    end
    it 'will return the status INVALID_REQUEST' do
      expect(json[:status]).to eq('INVALID_REQUEST')
    end
  end
end
