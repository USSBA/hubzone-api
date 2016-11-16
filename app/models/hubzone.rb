# A utility class to perform hubzone searches against the db
class Hubzone
  def self.search(term)
    return invalid_request("Search term is blank") if term.blank?

    g = Geocoder.search(term)
    geocoder_results = JSON.parse g.body
    case geocoder_results['status']
    when invalid_request[:status]
      return geocoder_results
    when zero_results[:status]
      return geocoder_results
    end

    results = geocoder_results['results'][0]
    results[:http_status] = g.status

    location = results['geometry']['location']
    results[:hubzone] = []
    %w(qct brac indian_lands).each do |hz_type|
      results[:hubzone] += assertion location, hz_type
    end
    results
  end

  def self.assertion(location, type)
    res = ActiveRecord::Base.connection.execute(assertion_query(location, type))
    hubzones = []
    res.each do |r|
      r.delete('geom')
      r[:hz_type] = type
      hubzones << r
    end
    hubzones
  end

  def self.assertion_query(location, type)
    <<-SQL
      SELECT *
        FROM #{type}
       WHERE ST_Intersects(geom,
         ST_GeomFromText('POINT(#{location['lng']} #{location['lat']})',4326));
    SQL
  end

  def self.invalid_request(message = "Invalid request")
    { status: 'INVALID_REQUEST',
      message: message,
      http_status: 400 }
  end
  def self.zero_results(message = "Zero results")
    { status: 'ZERO_RESULTS',
      message: message,
      http_status: 200 }
  end
end
