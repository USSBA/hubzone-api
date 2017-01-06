# Allows for assertion of a location against the QNMC HubZone layer
class QnmcAssertion
  extend AssertionHelper

  class << self
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def assertion(location)
      assertion_by_type('qnmc', location).each do |qnmc|
        qnmc['hz_type'] = 'qnmc_a'    if qnmc['unemployment']
        qnmc['hz_type'] = 'qnmc_b'    if qnmc['income']
        qnmc['hz_type'] = 'qnmc_ab'   if qnmc['income'] && qnmc['unemployment']
        qnmc['hz_type'] = 'qnmc_r'    if qnmc['redesignated']
        qnmc['hz_type'] = 'qnmc_brac' if qnmc['brac_id'].present?
        qnmc['hz_type'] = 'qnmc_c'    if qnmc['dda']
        qnmc
      end
    end
  end
end
