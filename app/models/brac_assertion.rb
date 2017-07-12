# Allows for assertion of a location against the BRAC HubZone layer
class BracAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      assertion_by_type 'brac', location
      assertion_by_type('brac', location).each do |brac|
        brac['brac_sba_name'] = brac['sba_name']
        brac['effective']     = brac['effective']
        brac
      end
    end
  end
end
