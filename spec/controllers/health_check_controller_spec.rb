require 'rails_helper'

describe HealthCheckController do
  describe 'GET :status' do
    it "will succeed" do
      get :status
      expect(response).to have_http_status(:ok)
    end
    it "will return simple text" do
      get :status
      expect(response.body).to eql("I'm OK")
    end
  end
end
