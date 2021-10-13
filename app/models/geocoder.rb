# a Class to encapsulate the api call to Google's geocoder API
# rubocop:disable Lint/UriEscapeUnescape
class Geocoder
  def self.search(term)
    Excon.new(geocoder_url(term)).get
  end

  def self.geocoder_url(search)
    "https://maps.googleapis.com/maps/api/geocode/json?address=#{URI.encode(search, /\W/)}&key=#{MAP_CONFIG[:google_api_key]}&country=US&country=UM"
  end
  # rubocop:enable Lint/UriEscapeUnescape
end
