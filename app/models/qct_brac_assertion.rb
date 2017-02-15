# Allows for assertion of a location against the QCT_brac HubZone layer
class QctBracAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      assertion_by_type('qct_brac', location).each do |qct|
        qct['hz_type'] = 'qct_b'    if qct['brac_id'].present?
        qct
      end
    end
  end
end
