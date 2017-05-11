# Allows for assertion of a location against the qnmc_qda HubZone layer
class QnmcQdaAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      qnmc_combined = {'expires' => '', 'hz_type' => 'qnmc_qda', 'qda' => []}
      assertion_by_type('qnmc_qda', location).each do |qnmc|
        next unless qnmc['qda_id'].present?
        qnmc_combined['qda'].push(qnmc)
        next if qnmc['expires'].nil?
        qnmc_combined['expires'] = qnmc['expires'] if qnmc['expires'] > qnmc_combined['expires']
      end
      qnmc_combined['qda'].empty? ? [] : [qnmc_combined]
    end
  end
end
