# A utility class to perform hubzone searches against the db
class HubzoneUtil
  class << self
    def search(term)
      return build_response("INVALID_REQUEST") if term.blank? || term.empty?

      results = geocode term
      error_status = error_check(results['status'])
      return error_status if error_status.present?

      append_assertions(results)
      results
    end

    private

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

    def build_response(status)
      code = status.eql?('ZERO_RESULTS') ? 200 : 400
      { status: status,
        message: 'api.error.' + status.downcase,
        http_status: code }
    end
  end
end
