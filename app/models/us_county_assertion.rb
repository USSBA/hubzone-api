  
# Allows for assertion of a location against the likely_qda HubZone layer
class UsCountyAssertion
    extend AssertionHelper
  
    class << self
      def assertion(location)
        congressional_districts = []
        assertion_by_type('data.tl_2021_us_county', location).each do |cd|
          puts "\n== query result US-county"
          puts cd
          cd['hz_type'] = 'us_county' 
          cd['tract_fips'] = cd['countyfp'] 
          cd['county'] =cd['namelsadco']
          cd['state'] = cd['state_name'] 
          cd['expires'] =nil
          congressional_districts.push(cd)
        end
        congressional_districts
      end
    end
  end
  