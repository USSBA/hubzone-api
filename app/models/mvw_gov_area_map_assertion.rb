# Allows for assertion of a location against the Governors Area HubZone layer
class MvwGovAreaMapAssertion
    extend AssertionHelper
  
    class << self
      def assertion(location)
        assertion_by_type 'mvw_gov_area_map', location
      end
    end
  end
