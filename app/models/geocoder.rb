class Geocoder < ActiveRecord::Base
  def self.search(s)
    searchStr = String.new('https://maps.googleapis.com/maps/api/geocode/json?address=' + s.to_s + '&key=' + MAP_CONFIG[:google_api_key].to_s + '&country=US&country=UM')
    response = Excon.get(searchStr)
    return response.headers, response.body, response.status
  end
end