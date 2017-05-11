# Allows for assertion of a location against the qnmc_brac HubZone layer
class QnmcBracAssertion
  extend AssertionHelper

  class << self
    # rubocop:disable Metrics/AbcSize
    def assertion(location)
      qnmc_combined = {'brac_id' => [], 'brac_sba_name' => [], 'expires' => '', 'hz_type' => 'qnmc_brac'}
      assertion_by_type('qnmc_brac', location).each do |qnmc|
        next unless qnmc['brac_id'].present?
        qnmc_combined['brac_id'].push(qnmc['brac_id'])
        qnmc_combined['brac_sba_name'].push(qnmc['brac_sba_name'])
        qnmc_combined['county_fips'] = qnmc['county_fips']
        next if qnmc['expires'].nil?
        qnmc_combined['expires'] = qnmc['expires'] if qnmc['expires'] > qnmc_combined['expires']
      end
      qnmc_combined['brac_id'].empty? ? [] : [qnmc_combined]
    end
  end
end
