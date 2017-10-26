class VerifiedHubzone
  attr_accessor :hubzone_results
  def initialize(hubzone_results)
    @hubzone_results = hubzone_results
    verify_likely_qda
    return @hubzone_results
  end

  private

  # HUB-934 only return likely qda status if certain other conditions are met
  def verify_likely_qda
    return @hubzone_results unless has_likely_qda
    @hubzone_results.except(:other_information[:alerts][:likely_qda]) unless contains_qualified_or_redesignated_hubzones || likely_qda_not_in_hubzone_types
  end

  def qualified_or_redesignated_hubzones
    %w[qct_e qct_r qnmc_e qnmc_r]
  end

  # checks if there are qualified or redesignated hubzones present in the hash
  def contains_qualified_or_redesignated_hubzones
    (@hubzone_results[:hubzone].map{ |o| o['hz_type'] } & qualified_or_redesignated_hubzones).present?
  end

  def likely_qda_not_in_hubzone_types
    (@hubzone_results[:hubzone].map{ |o| o['qda_id'] } & likely_qda_ids).empty?
  end

  def likely_qda_ids
    @hubzone_results[:other_information][:alerts][:likely_qda_designations].map{ |o| o['qda_id']}
  end

  def has_likely_qda
    @hubzone_results[:other_information] && @hubzone_results[:other_information][:alerts] && @hubzone_results[:other_information][:alerts][:likely_qda_designations]
  end
end
