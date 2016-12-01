# Allows for assertion of a location against the QCT HubZone layer
class QctAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      qct_res = assertion_by_type 'qct', location
      qct_res.each do |qct|
        qct_qual = qct['qualified_'] == 'Yes' || qct['qualified1'] == 'Yes'
        qct_brac = qct['brac_2016']
        qct['hz_type'] = 'brac' if qct_brac.present? && !qct_qual # WRONG?
        check_brac qct_res, qct, location if qct_brac.present?
        qct_res
      end
    end

    def check_brac(qct_res, qct, location)
      brac = BracAssertion.assertion location
      if brac.present?
        # if there is already a brac, delete this qct, since we want to show the brac instead
        qct_res.delete(qct)
      else
        # if there is no brac geometry, go find the brac attributes from the table and send those up as the qct attributes...
        brac = ActiveRecord::Base.connection.execute(BracAssertion.find_brac('sba_name', qct['brac_2016']))
        brac = brac[0]
        brac.delete('geom')
        brac['hz_type'] = 'brac'
        brac
      end
    end
  end
end
