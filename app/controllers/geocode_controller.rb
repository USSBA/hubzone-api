# The controller for handling geocoding
class GeocodeController < ApplicationController
  def search
    #s = params[:q]
    result = HubzoneUtil.search(q: params[:q], latlng: params[:latlng], query_date: params[:query_date])
    # Adds escape characters for single ' in the result JSON
    render json: result.to_json.gsub("'", "\\\\'"), status: result[:http_status]
  end
end
