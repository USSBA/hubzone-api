# Allows for assertion of a location against the QNMC HubZone layer
class QnmcAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      assertion_by_type('qnmc', location).each do |qnmc|
        qnmc_econ = qnmc['f2016_sba_'][0..2] != 'Not'
        qnmc_brac = qnmc['brac_2016'].present?
        qnmc['hz_type'] = if qnmc_brac && !qnmc_econ
                            'qnmc_b'
                          else
                            'qnmc_e'
                          end
        qnmc
      end
    end
  end
end
