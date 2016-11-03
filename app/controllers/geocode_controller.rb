# The controller for handling geocoding
class GeocodeController < ApplicationController
  def search
    s = params[:query]
    searchStr, body, status = Geocoder.search(s)
    render json: body.to_json, status: status
  end
end
