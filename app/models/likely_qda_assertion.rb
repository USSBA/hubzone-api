# Allows for assertion of a location against the likely_qct_qda HubZone layer
class LikelyQdaAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      # assertion_by_type('qnmc_qda', location)
      likely_qct_qda = [{}]
      likely_qct_qda[0]["hz_type"] = "likely_qda"
      likely_qct_qda[0]["likely_qda_designations"] = {}
      likely_qct_qda[0]["likely_qda_designations"]["type"] = "likely_qnmc_qda"
      likely_qct_qda[0]["likely_qda_designations"]["incident_description"] = "Hurriane Insane"
      likely_qct_qda[0]["likely_qda_designations"]["QDA Declaration"] = "2018-02-14"
      likely_qct_qda[0]["likely_qda_designations"]["type"] = "likely_qct_qda"
      likely_qct_qda[0]["likely_qda_designations"]["incident_description"] = "Hurriane Insane"
      likely_qct_qda[0]["likely_qda_designations"]["QDA Declaration"] = "2018-02-14"
      likely_qct_qda
    end
  end
end
