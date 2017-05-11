# Allows for assertion of a location against the qnmc_qda HubZone layer
class QctQdaAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      qct_combined = {'expires' => '', 'hz_type' => 'qct_qda', 'qda' => []}
      assertion_by_type('qct_qda', location).each do |qct|
        next unless qct['qda_id'].present?
        qct_combined['qda'].push(qct)
        next if qct['expires'].nil?
        qct_combined['expires'] = qct['expires'] if qct['expires'] > qct_combined['expires']
      end
      qct_combined['qda'].empty? ? [] : [qct_combined]
    end
  end
end
