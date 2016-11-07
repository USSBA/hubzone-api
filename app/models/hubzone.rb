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

    lat = results['geometry']['location']['lat']
    lgn = results['geometry']['location']['lng']
    res = ActiveRecord::Base.connection.execute(<<-SQL)
      SELECT il.*
        FROM indian_lands il
       WHERE ST_Intersects(il.geom,
                           ST_GeomFromText('POINT(#{lgn} #{lat})',4326));
    SQL
    hubzones = []
    res.each do |r|
      r.delete('geom')
      r[:hz_type] = 'indian_lands'
      hubzones << r
    end
    results[:hubzone] = hubzones
    results
  end

  private

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
