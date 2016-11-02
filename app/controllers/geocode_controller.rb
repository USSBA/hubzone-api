# The controller for handling geocoding
class GeocodeController < ApplicationController
  def search
    render json: { message: "ERROR" }.to_json, status: :not_found
  end
end
