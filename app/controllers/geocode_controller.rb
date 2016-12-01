# The controller for handling geocoding
class GeocodeController < ApplicationController
  def search
    #s = params[:q]
    result = HubzoneUtil.search(q: params[:q], latlng: params[:latlng])
    render json: result.to_json, status: result[:http_status]
  end
end
