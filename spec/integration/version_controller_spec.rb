require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe VersionController, vcr: false, type: :request do
  MAP_CONFIG[:hubzone_api_version] = {
    major: 100,
    minor: 50,
    patch: 1000,
    pre_release: 'zeta'
  }

  describe "Get version data in html" do
    before do
      get version_url, params: {format: 'html'}
    end
    it "will show the current version of the api software" do
      expect(response.body).to match(/v100.50.\d+(-[a-zA-Z0-9.]+)? \([a-f0-9]{7}\)/)
    end
  end
  describe "Get version data in json" do
    before do
      get version_url, params: {format: 'json'}
    end
    it "will return the major version of the api software" do
      expect(json[:major]).to eq(100)
    end
    it "will return the minor version of the api software" do
      expect(json[:minor]).to eq(50)
    end
    it "will return the patch version of the api software" do
      expect(json[:patch]).to eq(1000)
    end
    it "will return the pre_release version of the api software" do
      expect(json[:pre_release]).to eq('zeta')
    end
    it "will return the commit of the api software" do
      expect(json[:commit_sha]).not_to be_nil
    end
    it "will return the tag of the api software" do
      expect(json[:tag]).not_to be_nil
    end
    it "will return the delta of the api software" do
      expect(json[:delta]).not_to be_nil
    end
  end
end
