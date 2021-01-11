# helper class for applying additional business logic rules to the hubzone API assertion response
class VerifiedHubzone
  attr_accessor :hubzone_results
  def initialize(hubzone_results)
    @hubzone_results = hubzone_results
    verify_likely_qda
  end

  private

  # HUB-934 only return likely qda status if certain other conditions are met
  def verify_likely_qda
    #doesn't have a likely_qda, skip verification
    return @hubzone_results unless likely_qda?

    # NDAA 2018:
    # need to differentiate betweeen showing likely_qda for qct_r and qnmc_r vs qct_e and qnmc_e
    # since it is now not possible for qualified hubzones to expire prior to 2021, \
    # therefore they are not likely to get qda

    # level 1a: likely_qda is present and IS qct_e qnmc_e = do not show likely_qda
    return drop_likely_qda unless contains_redesignated_hubzones

    # level 2: likely_qda is present and IS qct_r qnmc_r = do not show likely_qda
    return @hubzone_results if contains_redesignated_hubzones_not_qda_hubzones

    # level 2: likely_qda is present, location DOES have qnmc_r, location DOES NOT have QDA hubzones = DO show likely_qda
    # return @hubzone_results unless contains_qda_hubzones

    # level 3: likely_qda is present, location DOES have qct_e qct_r qnmc_e qnmc_r, location DOES have QDA hubzones
    # if qnmc_qda or qct_qda are in likely_qda, do not show likely_qda else show the likely_qda
    hubzone_qdas = likely_qda_in_hubzones
    remove_qdas hubzone_qdas if hubzone_qdas

    # finally remove the likely_qda_designation hash if it is now empty to keep it consistent with status if it is not present
    @hubzone_results[:other_information][:alerts].except!(:likely_qda_designations) if @hubzone_results[:other_information][:alerts][:likely_qda_designations].empty?
  end

  def hubzone_types
    @hubzone_results[:hubzone].map { |o| o['hz_type'] }
  end

  def qualified_or_redesignated_hubzones
    %w[qct_e qct_r qnmc_r qnmc_r qnmc_a qnmc_b qnmc_c qnmc_ab qnmc_ac qnmc_bc qnmc_abc]
  end

  def qualified_hubzones
    %w[qct_e qnmc_a qnmc_b qnmc_c qnmc_ab qnmc_ac qnmc_bc qnmc_abc mvw_gov_area_map]
  end

  def redesignated_hubzones
    %w[qct_r qnmc_r]
  end

  def qda_hubzones
    %w[qct_qda qnmc_qda]
  end


  # checks if there are qualified hubzones present in the hash
  def contains_qualified_hubzones
    (hubzone_types & qualified_hubzones).present?
  end

  # checks if there are qualified hubzones present in the hash
  def contains_redesignated_hubzones
    (hubzone_types & redesignated_hubzones).present?
  end

  # checks if there are qualified or redesignated hubzones present in the hash
  def contains_qualified_or_redesignated_hubzones
    (hubzone_types & qualified_or_redesignated_hubzones).present?
  end

  # returns true if the hubzone types contains redesignated but not qdas
  def contains_redesignated_hubzones_not_qda_hubzones
    contains_redesignated_hubzones && !contains_qda_hubzones
  end

  # checks if there are qda hubzones present in the hash
  def contains_qda_hubzones
    (hubzone_types & qda_hubzones).present?
  end

  # return an array of likely_qdas if the likely_qda is already present in the hubzone designations
  def likely_qda_in_hubzones
    @hubzone_results[:other_information][:alerts][:likely_qda_designations].map do |qda|
      qda if likely_hubzone_qda_ids.include?(unique_qda(qda))
    end
  end

  def likely_hubzone_qda_ids
    @hubzone_results[:hubzone].map do |hz|
      unique_qda(hz) if qda_hubzones.include?(hz['hz_type'])
    end
  end

  # return a unique identifying qda string for each qda snce there are no official qda_ids per declaration and the db can have multiple versions/rows of the same declaration
  def unique_qda(qda)
    identifying_props = %w[disaster_state disaster_type qda_declaration incident_description county_fips]
    unique_qda_string = []
    identifying_props.each do |p|
      unique_qda_string.push(qda[p].to_s)
    end
    unique_qda_string.join("_")
  end

  def likely_qda?
    @hubzone_results.dig(:other_information, :alerts, :likely_qda_designations)
  end

  def drop_likely_qda
    @hubzone_results[:other_information][:alerts].except!(:likely_qda_designations)
  end

  def remove_qdas(hubzone_qdas)
    @hubzone_results[:other_information][:alerts][:likely_qda_designations] = @hubzone_results[:other_information][:alerts][:likely_qda_designations] - hubzone_qdas
  end
end
