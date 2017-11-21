# Allows for assertion of a location against the likely_qda HubZone layer
class CongressionalDistrictAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      congressional_districts = []
      assertion_by_type('congressional_districts', location).each do |cd|
        congressional_districts.push(cd.except!("hz_type"))
      end
      congressional_districts
    end
  end
end
