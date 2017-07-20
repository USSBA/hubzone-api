# Allows for assertion of a location against the qct_brac HubZone layer
class QctBracAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      qct_combined = new_qct_brac_assertion
      assertion_by_type('qct_brac', location).each do |qct|
        next unless qct['brac_id'].present?
        qct_combined = combine_qct_values qct, qct_combined
        qct_combined['expires'] = parse_expiration qct, qct_combined
      end

      qct_combined = join_array_values qct_combined
      qct_combined['brac_id'].empty? ? [] : [qct_combined]
    end

    def new_qct_brac_assertion
      { 'brac_id' => [],
        'brac_sba_name' => [],
        'fac_type' => [],
        'effective' => [],
        'tract_fips' => '',
        'county' => '',
        'state' => '',
        'expires' => '',
        'closure' => [],
        'hz_type' => 'qct_brac' }
    end

    def combine_qct_values(qct, qct_combined)
      # since these keys are uniuq, keep them all
      %w[brac_id brac_sba_name fac_type effective closure].each do |k|
        qct_combined[k].push(qct[k])
      end

      # just keep one record for these keys
      %w[tract_fips county state].each do |k|
        qct_combined[k] = qct[k]
      end
      qct_combined
    end

    def join_array_values(qct_combined)
      %w[brac_id brac_sba_name fac_type effective closure].each do |k|
        next if qct_combined[k].blank?
        qct_combined[k] = qct_combined[k].join('; ')
      end
      qct_combined
    end

    def parse_expiration(qct, qct_combined)
      return '' if qct['expires'].nil?
      qct['expires'] > qct_combined['expires'] ? qct['expires'] : qct_combined['expires']
    end
  end
end
