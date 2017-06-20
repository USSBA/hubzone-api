# Allows for assertion of a location against the qnmc_qda HubZone layer
class QnmcQdaAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      qnmc_combined = new_qnmc_qda_assertion
      assertion_by_type('qnmc_qda', location).each do |qnmc|
        next unless qnmc['qda_id'].present?
        qnmc_combined = combine_qnmc_values qnmc, qnmc_combined
        qnmc_combined['expires'] = parse_expiration qnmc, qnmc_combined
      end
      qnmc_combined = join_array_values qnmc_combined
      qnmc_combined['qda_id'].empty? ? [] : [qnmc_combined]
    end

    def new_qnmc_qda_assertion
      { 'incident_description' => [],
        'qda_declaration' => [],
        'qda_designation' => [],
        'qda_publish' => [],
        'qda_id' => [],
        'county_fips' => '',
        'county_name' => '',
        'state' => '',
        'expires' => '',
        'hz_type' => 'qnmc_qda' }
    end

    def combine_qnmc_values(qnmc, qnmc_combined)
      # since these keys are uniuq, keep them all
      %w[incident_description qda_declaration qda_designation qda_publish qda_id].each do |k|
        qnmc_combined[k].push(qnmc[k])
      end

      # just keep one record for these keys
      %w[county_fips county_name state].each do |k|
        qnmc_combined[k] = qnmc[k]
      end
      qnmc_combined
    end

    def parse_expiration(qnmc, qnmc_combined)
      return '' if qnmc['expires'].nil?
      qnmc['expires'] > qnmc_combined['expires'] ? qnmc['expires'] : qnmc_combined['expires']
    end

    def join_array_values(qnmc_combined)
      %w[incident_description qda_declaration qda_designation qda_publish qda_id].each do |k|
        next if qnmc_combined[k].blank?
        qnmc_combined[k] = qnmc_combined[k].join('; ')
      end
      qnmc_combined
    end
  end
end
