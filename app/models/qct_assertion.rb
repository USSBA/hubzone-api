# Allows for assertion of a location against the QCT HubZone layer
class QctAssertion
  extend AssertionHelper

  class << self
    def assertion(location)
      qct = assertion_by_type 'qct', location
      qct.each do |q|
        qct_qual = q['qualified_'] || q['qualified1']
        qct_brac = q['brac_2016']
        q['hz_type'] = 'brac' if qct_brac && !qct_qual # WRONG?

        check_brac qct, q, location if qct_brac

        qct
      end
    end

    def check_brac(qct, q, location)
      brac = BracAssertion.assertion location
      if brac
        qct.delete(q)
      else
        # ugh, find the brac...
        brac = BracAssertion.find_brac 'sba_name', q['brac_2016']
        q << brac
      end
    end
  end
end
