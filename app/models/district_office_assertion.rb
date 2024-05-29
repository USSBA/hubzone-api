
# Allows for assertion of a location against the likely_qda HubZone layer
class DistrictOfficeAssertion
    extend AssertionHelper
  
    class << self
      def assertion(location)
        sba_district_office = []
        assertion_by_type('sba_do', location).each do |cd|
          puts "\n== query result census_tractt"
          puts cd
          cd['hz_type'] = 'sba_do' 
          cd['sba_district_office'] = cd['sba_district_office'] 
          sba_district_office.push(cd)
        end
        sba_district_office
      end
    end
  end
  