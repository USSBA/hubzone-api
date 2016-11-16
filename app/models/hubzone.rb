# A utility class to perform hubzone searches against the db
class Hubzone
  def self.search(term)
    return invalid_request("Search term is blank") if term.blank?

    geocoder_results = geocode term
    return geocoder_results if (geocoder_results.eql? invalid_request[:status]) ||
                               (geocoder_results.eql? zero_results[:status])

    results = geocode term
    append_assertions(results)
    results
  end

  class << self
    private

    def geocode(term)
      g = Geocoder.search(term)
      geocoder_results = JSON.parse g.body
      return geocoder_results if (geocoder_results.eql? invalid_request[:status]) ||
                                 (geocoder_results.eql? zero_results[:status])
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

    def invalid_request(message = "Invalid request")
      { status: 'INVALID_REQUEST',
        message: message,
        http_status: 400 }
    end

    def zero_results(message = "Zero results")
      { status: 'ZERO_RESULTS',
        message: message,
        http_status: 200 }
    end
  end
end
