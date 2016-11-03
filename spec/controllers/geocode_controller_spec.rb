require 'rails_helper'

RSpec.describe GeocodeController, type: :controller do

  describe "POST #search" do
    it "returns http success" do
      query = "8 Market Pl., Baltimore, MD  21202"
      post :search, {query: query}, 'Content-Type' => 'application/json'
      expect(response).to have_http_status(:success)
    end
  end

end
