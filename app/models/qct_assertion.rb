# Allows for assertion of a location against the QCT HubZone layer
class QctAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      assertion_by_type('qct', location).each do |qct|
        qct['hz_type'] = 'qct_e'    if qct['current_status'] == 'Qualified'
        qct['hz_type'] = 'qct_r'    if qct['redesignated']
        # qct
      end
    end
  end
end
