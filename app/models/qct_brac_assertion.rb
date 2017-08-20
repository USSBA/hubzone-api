# Allows for assertion of a location against the qct_brac HubZone layer
class QctBracAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      assertion_by_type('qct_brac', location)
    end
  end
end
