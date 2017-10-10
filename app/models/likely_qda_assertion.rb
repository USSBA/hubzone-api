# Allows for assertion of a location against the likely_qda HubZone layer
class LikelyQdaAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      likely_qdas = []
      assertion_by_type('likely_qda', location).each do |qda|
        likely_qda = {}
        likely_qda["incident_description"] = qda["incident_description"]
        likely_qda["qda_declaration"] = qda["declaration_date"]
        likely_qdas.push(likely_qda)
      end
      likely_qdas
    end
  end
end
