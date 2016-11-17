class Hubzone
  def self.search(term)
    return invalid_request("api.error.blank_search") if term.blank?

    g = Geocoder.search(term)
    geocoder_results = JSON.parse g.body
    case geocoder_results['status']
    when invalid_request[:status]
      return invalid_request()
    when zero_results[:status]
      return zero_results()
    when over_limit[:status]
      return over_limit()
    when request_denied[:status]
      return request_denied()
    when unknown_error[:status]
      return unknown_error()
    end

    results = geocoder_results['results'][0]
    results[:http_status] = g.status
    results[:message] = 'api.success'
    results[:status] = 'OK'

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

  def self.zero_results(message = "api.error.zero_results")
    { status: 'ZERO_RESULTS',
      message: message,
      http_status: 200 }
  end
  def self.invalid_request(message = "api.error.invalid_request")
    { status: 'INVALID_REQUEST',
      message: message,
      http_status: 400 }
  end
  def self.over_limit(message = "api.error.over_query_limit")
    { status: 'OVER_QUERY_LIMIT',
      message: message,
      http_status: 400 }
  end
  # request denied can come from a bad API key, which google returns as 200, but we are sending it as 400 
  def self.request_denied(message = "api.error.request_denied")
    { status: 'REQUEST_DENIED',
      message: message,
      http_status: 400 }
  end
  def self.unknown_error(message = "api.error.unknown_error")
    { status: 'UNKNOWN_ERROR',
      message: message,
      http_status: 400 }
  end
end
