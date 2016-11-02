require 'rails_helper'

RSpec.describe GeocodeController, type: :controller do

  describe "POST #search" do
    it "returns http success" do
      params = { search: "8 Market Pl., Baltimore, MD  21202" }.to_json
      post :search, params, "CONTENT_TYPE" => 'application/json'
      expect(response).to have_http_status(:success)
    end
  end

end
