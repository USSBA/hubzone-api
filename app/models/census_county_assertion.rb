
# Allows for assertion of a location against the likely_qda HubZone layer
class CensusCountyAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      congressional_districts = []
      assertion_by_type('census_county', location).each do |cd|
        puts "\n== query resultcensus_county"
        puts cd
        cd['hz_type'] = 'census_county' 
        cd['CountyID'] = cd['countyfp'] 
        cd['County'] = cd['namelsad']
        congressional_districts.push(cd)
      end
      congressional_districts
    end
  end
end
