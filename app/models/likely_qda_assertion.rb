# Allows for assertion of a location against the likely_qda HubZone layer
class LikelyQdaAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      likely_qda = [{}]
      likely_qda[0]["hz_type"] = "likely_qda"
      # likely_qda[0]["likely_qda_designations"] = []
      # likely_qda[0]["likely_qda_designations"].push assertion_by_type('likely_qnmc_qda', location)
      # likely_qda[0]["likely_qda_designations"].push assertion_by_type('likely_qct_qda', location)

      likely_qda[0]["likely_qda_designations"] = [
        {
          "type": "likely_qct_qda",
          "incident_description": "Hurricane Irma",
          "qda_declaration": "2017-09-15"
        },
        {
          "type": "likely_qnmc_qda",
          "incident_description": "Hurricane Maria",
          "qda_declaration": "2017-09-20"
        },
        {
          "type": "likely_qnmc_qda",
          "incident_description": "Hurricane Irma - Seminole Tribe of Florida,",
          "qda_declaration": "2017-09-27"
        },
        {
          "type": "likely_qct_qda",
          "incident_description": "Severe Storms, Tornadoes, Straight-line Winds, and Flooding",
          "qda_declaration": "2017-08-06"
        }
      ]
      likely_qda
    end
  end
end



