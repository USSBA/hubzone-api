# Allows for assertion of a location against the qnmc_brac HubZone layer
class QnmcBracAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      assertion_by_type('qnmc_brac', location)
    end
  end
end
