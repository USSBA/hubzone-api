# Allows for assertion of a location against the BRAC HubZone layer
class BracAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      assertion_by_type 'brac', location
    end

    def find_brac(field, value)
      <<-SQL
      SELECT *
        FROM brac
       WHERE #{field} = '#{value}'
      SQL
    end
  end
end
