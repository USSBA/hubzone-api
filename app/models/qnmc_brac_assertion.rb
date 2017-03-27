# Allows for assertion of a location against the qnmc_brac HubZone layer
class QnmcBracAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      qnmc_combined = {}
      qnmc_combined['brac_id'] = []
      qnmc_combined['brac_sba_name'] = []
      qnmc_combined['expires'] = []
      assertion_by_type('qnmc_brac', location).each do |qnmc|
        if qnmc['brac_id'].present?
          qnmc_combined['brac_id'].push(qnmc['brac_id'])
          qnmc_combined['hz_type'] = 'qnmc_brac'
          qnmc_combined['brac_sba_name'].push(qnmc['brac_sba_name'])
          qnmc_combined['county_fips'] = qnmc['county_fips']
          unless qnmc['expires'].nil?
            qnmc_combined['expires'].push(qnmc['expires'].to_date)
          end
        end
      end

      if qnmc_combined['brac_id'].empty?
        return []
      else
        qnmc_combined['expires'] = qnmc_combined['expires'].max
        qnmc_combined['brac_sba_name'] = qnmc_combined['brac_sba_name'].join('; ')
        qnmc_combined['brac_id'] = qnmc_combined['brac_id'].join('; ')
        return [qnmc_combined]
      end
    end
  end
end
