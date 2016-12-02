# Allows for assertion of a location against the QCT HubZone layer
class QctAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      assertion_by_type('qct', location).each do |qct|
        qct_econ = qct['qualified_'] == 'Yes' || qct['qualified1'] == 'Yes'
        qct_brac = qct['brac_2016'].present?
        qct['hz_type'] = if qct_brac && !qct_econ
                           'qct_b'
                         else
                           'qct_e'
                         end
        qct
      end
    end
  end
end
