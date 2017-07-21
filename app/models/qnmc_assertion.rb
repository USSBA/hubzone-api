# Allows for assertion of a location against the QNMC HubZone layer
class QnmcAssertion
  extend AssertionHelper

  class << self
    #rubocop:disable MethodLength
    #rubocop:disable Metrics/AbcSize
    #rubocop:disable Metrics/CyclomaticComplexity
    #rubocop:disable Metrics/PerceivedComplexity
    def assertion(location)
      assertion_by_type('qnmc', location).each do |qnmc|
        qnmc['hz_type'] = 'qnmc_r'    if qnmc_r qnmc
        qnmc['hz_type'] = 'qnmc_a'    if qnmc_a qnmc
        qnmc['hz_type'] = 'qnmc_b'    if qnmc_b qnmc
        qnmc['hz_type'] = 'qnmc_c'    if qnmc_c qnmc
        qnmc['hz_type'] = 'qnmc_ab'   if qnmc_ab qnmc
        qnmc['hz_type'] = 'qnmc_ac'   if qnmc_ac qnmc
        qnmc['hz_type'] = 'qnmc_bc'   if qnmc_bc qnmc
        qnmc['hz_type'] = 'qnmc_abc'  if qnmc_abc qnmc
        qnmc
      end
    end

    private

    def qnmc_r(qnmc)
      qnmc['redesignated']
    end

    def qnmc_a(qnmc)
      qnmc['income'] && !qnmc['unemployment'] && !qnmc['dda']
    end

    def qnmc_b(qnmc)
      !qnmc['income'] && qnmc['unemployment'] && !qnmc['dda']
    end

    def qnmc_c(qnmc)
      !qnmc['income'] && !qnmc['unemployment'] && qnmc['dda']
    end

    def qnmc_ab(qnmc)
      qnmc['income'] && qnmc['unemployment'] && !qnmc['dda']
    end

    def qnmc_ac(qnmc)
      qnmc['income'] && !qnmc['unemployment'] && qnmc['dda']
    end

    def qnmc_bc(qnmc)
      !qnmc['income'] && qnmc['unemployment'] && qnmc['dda']
    end

    def qnmc_abc(qnmc)
      qnmc['income'] && qnmc['unemployment'] && qnmc['dda']
    end
  end
end
