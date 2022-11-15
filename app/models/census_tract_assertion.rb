
# Allows for assertion of a location against the likely_qda HubZone layer
class CensusTaractAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      congressional_districts = []
      assertion_by_type('census_tract', location).each do |cd|
        puts "\n== query result census_tractt"
        puts cd
        cd['hz_type'] = 'census_tract' 
        cd['TractID'] = cd['geoid'] 
        congressional_districts.push(cd)
      end
      congressional_districts
    end
  end
end
