# A utility class to perform hubzone searches against the db
class HubzoneUtil
  class << self
    def search(params)
      results = if !params[:q].nil?
                  search_by_query params[:q]
                elsif !params[:latlng].nil?
                  search_by_latlng params[:latlng]
                else
                  build_response("INVALID_REQUEST")
                end
      append_search_values results, params
    end

    private

    def append_search_values(results, params)
      results[:query_date] = params[:query_date]
      results[:search_q] = params[:q]
      results[:search_latlng] = params[:latlng]
      results
    end

    def search_by_query(term)
      return build_response("INVALID_REQUEST") if term.blank? || term.empty?

      results = geocode term
      # byebug
      error_status = error_check(results['status'])
      return error_status if error_status.present?

      append_assertions(results)
      latest_expiration(results)
      results
    end

    def search_by_latlng(loc)
      return build_response("INVALID_REQUEST") if loc.blank? || loc.empty?
      regex = /\A[-+]?[0-9]*\.?[0-9]+,[-+]?[0-9]*\.?[0-9]+\Z/
      return build_response("INVALID_REQUEST") if regex.match(loc).nil?

      results = default_location_results loc
      append_assertions(results)
      latest_expiration(results)
      results
    end

    def default_location_results(loc)
      lat, lng = loc.split(',')
      {
        'formatted_address' => [format('%.6f', lat) + "\xC2\xB0", format('%.6f', lng) + "\xC2\xB0"].join(', '),
        'geometry' => {
          'location' => {
            'lat' => lat.to_f,
            'lng' => lng.to_f
          }
        }
      }
    end

    def error_check(status)
      statuses = %w[ZERO_RESULTS INVALID_REQUEST OVER_QUERY_LIMIT REQUEST_DENIED UNKNOWN_ERROR]
      return build_response(status) if statuses.include?(status)
    end

    def geocode(term)
      g = Geocoder.search(term)
      geocoder_results = JSON.parse g.body
      return geocoder_results unless geocoder_results['status'].eql? 'OK'

      results = geocoder_results['results'][0]
      results[:http_status] = g.status
      results
    end

    def append_assertions(results)
      results[:hubzone] = []
      location = results['geometry']['location']

      # maybe we need another word other than assertion
      %w[Brac Qct QctBrac Qnmc QnmcBrac QnmcQda QctQda IndianLands].each do |assertion_type|
        hz_assertion = "#{assertion_type}Assertion".constantize
        results[:hubzone] += hz_assertion.assertion location
      end
    end

    #rubocop:disable MethodLength
    def latest_expiration(results)
      dates = []
      has_indefinite_expiration = false
      results[:hubzone].each do |result|
        if result['expires'].nil?
          has_indefinite_expiration = true
        elsif !result['expires'].nil?
          d = Date.parse(result['expires'])
          dates.push d
        end
      end
      results[:until_date] = has_indefinite_expiration ? nil : dates.max
    end

    def build_response(status)
      code = status.eql?('ZERO_RESULTS') ? 200 : 400
      { status: status,
        message: 'api.error.' + status.downcase,
        http_status: code }
    end
  end
end
