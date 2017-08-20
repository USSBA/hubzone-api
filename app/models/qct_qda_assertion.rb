# Allows for assertion of a location against the qct_qda HubZone layer
class QctQdaAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      assertion_by_type('qct_qda', location)
    end
  end
end
