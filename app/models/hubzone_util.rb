# A utility class to perform hubzone searches against the db
class HubzoneUtil
  class << self
    def search(params)
      if !params[:q].nil?
        search_by_query params[:q]
      elsif !params[:latlng].nil?
        search_by_latlng params[:latlng]
      else
        build_response("INVALID_REQUEST")
      end
    end

    private

    def search_by_query(term)
      return build_response("INVALID_REQUEST") if term.blank? || term.empty?

      results = geocode term
      error_status = error_check(results['status'])
      return error_status if error_status.present?

      append_assertions(results)
      results
    end

    def search_by_latlng(loc)
      return build_response("INVALID_REQUEST") if loc.blank? || loc.empty?

      results = default_location_results loc
      append_assertions(results)
      results
    end

    def default_location_results(loc)
      lat, lng = loc.split(',')
      {
        'formatted_address' => loc.gsub(',', ', '),
        'geometry' => {
          'location' => {
            'lat' => lat.to_f,
            'lng' => lng.to_f
          }
        }
      }
    end

    def error_check(status)
      statuses = %w(ZERO_RESULTS INVALID_REQUEST OVER_QUERY_LIMIT REQUEST_DENIED UNKNOWN_ERROR)
      return build_response(status) if statuses.include?(status)
    end

    def geocode(term)
      g = Geocoder.search(term)
      geocoder_results = JSON.parse g.body
      return geocoder_results if geocoder_results['status'].eql? 'INVALID_REQUEST'
      return geocoder_results if geocoder_results['status'].eql? 'ZERO_RESULTS'

      results = geocoder_results['results'][0]
      results[:http_status] = g.status
      results
    end

    def append_assertions(results)
      results[:hubzone] = []
      location = results['geometry']['location']

      # Check first for BRAC
      brac = BracAssertion.assertion location
      results[:hubzone] += brac

      # Then QCTs
      qct = QctAssertion.assertion location
      results[:hubzone] += qct

      # Then Indian Lands
      il = IndianLandsAssertion.assertion location
      results[:hubzone] += il
    end

    def build_response(status)
      code = status.eql?('ZERO_RESULTS') ? 200 : 400
      { status: status,
        message: 'api.error.' + status.downcase,
        http_status: code }
    end
  end
end
