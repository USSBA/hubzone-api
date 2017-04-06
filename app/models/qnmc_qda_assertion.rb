# Allows for assertion of a location against the qnmc_qda HubZone layer
class QnmcQdaAssertion
  extend AssertionHelper

  class << self
    # rubocop:disable Metrics/AbcSize
    def assertion(location)
      qnmc_combined = {'qda_id' => [], 'expires' => '', 'hz_type' => 'qnmc_qda'}
      assertion_by_type('qnmc_qda', location).each do |qnmc|
        next unless qnmc['qda_id'].present?
        qnmc_combined['qda_id'].push(qnmc['qda_id'])
        qnmc_combined['county_fips'] = qnmc['county_fips']
        next if qnmc['expires'].nil?
        qnmc_combined['expires'] = qnmc['expires'] if qnmc['expires'] > qnmc_combined['expires']
      end
      qnmc_combined['qda_id'].empty? ? [] : [qnmc_combined]
    end
  end
end
