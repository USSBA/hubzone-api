# Allows for assertion of a location against the QCT HubZone layer
class QctAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      qct_res = assertion_by_type 'qct', location
      qct_res.each do |qct|
        qct['hz_type'] = 'qct_e'
        qct_qual = qct['qualified_'] == 'Yes' || qct['qualified1'] == 'Yes'
        qct_brac = qct['brac_2016']
        qct['hz_type'] = 'qct_b' if qct_brac.present? && !qct_qual
        qct
      end
    end
  end
end
