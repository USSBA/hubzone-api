# Allows for assertion of a location against the Indian Lands HubZone layer
class IndianLandsAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      assertion_by_type 'indian_lands', location
    end
  end
end
