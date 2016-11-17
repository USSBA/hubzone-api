# A utility class to perform hubzone searches against the db
class HubzoneUtil
  class << self
    def search(term)
      return parse_response("BLANK_SEARCH_TERM", 400) if term.blank? || term.empty?

      results = geocode term
      error_status = error_check(results['status'])
      return error_status if error_status.present?

      append_assertions(results)
      results
    end

    private

    def error_check(status)
      return parse_response(status, 200) if status.eql? 'ZERO_RESULTS'
      return parse_response(status, 400) if status.eql? 'INVALID_REQUEST'
      return parse_response(status, 400) if status.eql? 'OVER_QUERY_LIMIT'
      return parse_response(status, 400) if status.eql? 'REQUEST_DENIED'
      return parse_response(status, 400) if status.eql? 'UNKNOWN_ERROR'
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
      %w(qct brac indian_lands).each do |hz_type|
        results[:hubzone] += assertion results['geometry']['location'], hz_type
      end
    end

    def assertion(location, type)
      res = ActiveRecord::Base.connection.execute(assertion_query(location, type))
      hubzones = []
      res.each do |r|
        r.delete('geom')
        r[:hz_type] = type
        hubzones << r
      end
      hubzones
    end

    def assertion_query(location, type)
      <<-SQL
      SELECT *
        FROM #{type}
       WHERE ST_Intersects(geom,
         ST_GeomFromText('POINT(#{location['lng']} #{location['lat']})',4326));
      SQL
    end

    def parse_response(error_status, http_status)
      { status: error_status,
        message: 'api.error.' + error_status.downcase,
        http_status: http_status }
    end
  end
end
