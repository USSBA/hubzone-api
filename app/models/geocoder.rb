class Geocoder
  def self.search(term)
    Faraday.get(geocoder_url term)
  end

  def self.geocoder_url(search)
    'https://maps.googleapis.com/maps/api/geocode/json?address=' +
      URI.encode(search, /\W/) +
      '&key=' +
      MAP_CONFIG[:google_api_key] +
      '&country=US&country=UM'
  end
end
