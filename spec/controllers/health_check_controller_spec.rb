require 'rails_helper'

describe HealthCheckController do
  describe 'GET :status' do
    it "should succeed" do
      get :status
      expect(response).to have_http_status(:ok)
    end
    it "should return simple text" do
      get :status
      expect(response.body).to eql("I'm OK")
    end
  end
end
