# Allows for assertion of a location against the qnmc_qda HubZone layer
class QnmcQdaAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      assertion_by_type('qnmc_qda', location)
    end
  end
end
