# a constraints class to properly route the api requests based upon the API version
# specified in the request header 'Accept' field.
class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    @default || req.headers['Accept'].include?("application/sba.hubzone-api.v#{@version}")
  end
end
