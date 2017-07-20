# Allows for assertion of a location against the qnmc_brac HubZone layer
class QnmcBracAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      qnmc_combined = new_qnmc_brac_assertion
      assertion_by_type('qnmc_brac', location).each do |qnmc|
        next unless qnmc['brac_id'].present?
        qnmc_combined = combine_qnmc_values qnmc, qnmc_combined
        qnmc_combined['expires'] = parse_expiration qnmc, qnmc_combined
      end
      qnmc_combined = join_array_values qnmc_combined
      qnmc_combined['brac_id'].empty? ? [] : [qnmc_combined]
    end

    def new_qnmc_brac_assertion
      { 'brac_id' => [],
        'brac_sba_name' => [],
        'fac_type' => [],
        'effective' => [],
        'county_fips' => '',
        'county' => '',
        'state' => '',
        'expires' => '',
        'closure' => '',
        'hz_type' => 'qnmc_brac' }
    end

    def combine_qnmc_values(qnmc, qnmc_combined)
      # since these keys are uniuq, keep them all
      %w[brac_id brac_sba_name fac_type effective closure].each do |k|
        qnmc_combined[k].push(qnmc[k])
      end

      # just keep one record for these keys
      %w[county_fips county state].each do |k|
        qnmc_combined[k] = qnmc[k]
      end
      qnmc_combined
    end

    def join_array_values(qnmc_combined)
      %w[brac_id brac_sba_name fac_type effective closure].each do |k|
        next if qnmc_combined[k].blank?
        qnmc_combined[k] = qnmc_combined[k].join('; ')
      end
      qnmc_combined
    end

    def parse_expiration(qnmc, qnmc_combined)
      return '' if qnmc['expires'].nil?
      qnmc['expires'] > qnmc_combined['expires'] ? qnmc['expires'] : qnmc_combined['expires']
    end
  end
end
