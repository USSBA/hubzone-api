# The controller for handling geocoding
module Api
  module V2
    # The Geocode Controller for V2 of the Geo API
    class GeocodeController < ApplicationController
      def search
        #s = params[:q]
        result = HubzoneUtil.search(q: params[:q], latlng: params[:latlng], query_date: params[:query_date])
        result[:api_version] = 2
        # Adds escape characters for single ' in the result JSON
        render json: result.to_json.gsub("'", "\\\\'"), status: result[:http_status]
      end
    end
  end
end
