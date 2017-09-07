require 'rails_helper'
require 'helpers/test_data_helper'

RSpec.describe HubzoneUtil do

  context "empty search" do
    it "is a test" do
      params = { message: "something" }
      results = HubzoneUtil.search params
      # byebug
      expect(results[:status]).to match("INVALID_REQUEST")
    end
  end
end
