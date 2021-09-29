# Allows for assertion of a location against the BRAC HubZone layer
class MvwGovAreaMapCountyAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      assertion_by_type 'mvw_gov_area_map_county', location
    end
  end
end
