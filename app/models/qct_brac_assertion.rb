# Allows for assertion of a location against the qct_brac HubZone layer
class QctBracAssertion
  extend AssertionHelper

  class << self
    # rubocop:disable Metrics/AbcSize
    def assertion(location)
      qct_combined = {'brac_id' => [], 'brac_sba_name' => [], 'expires' => '', 'hz_type' => 'qct_brac'}
      assertion_by_type('qct_brac', location).each do |qct|
        next unless qct['brac_id'].present?
        qct_combined['brac_id'].push(qct['brac_id'])
        qct_combined['brac_sba_name'].push(qct['brac_sba_name'])
        qct_combined['county_fips'] = qct['county_fips']
        next if qct['expires'].nil?
        qct_combined['expires'] = qct['expires'] if qct['expires'] > qct_combined['expires']
      end
      qct_combined['brac_id'].empty? ? [] : [qct_combined]
    end
  end
end
