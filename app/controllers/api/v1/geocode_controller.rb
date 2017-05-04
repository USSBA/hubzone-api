# The controller for handling geocoding
module Api
  module V1
    # The Geocode Controller for V1 of the Geo API
    class GeocodeController < ApplicationController
      def search
        #s = params[:q]
        result = HubzoneUtil.search(q: params[:q], latlng: params[:latlng], query_date: params[:query_date])
        result[:api_version] = 1
        # Adds escape characters for single ' in the result JSON
        render json: result.to_json.gsub("'", "\\\\'"), status: result[:http_status]
      end
    end
  end
end
