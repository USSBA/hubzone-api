require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe VersionController do
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
      expect(response.body).to match(/v\d+.\d+.\d+(-[a-zA-Z0-9.]+)? \([a-f0-9]{7}\)/)
    end
  end
  describe "Get version data in json" do
    before do
      get version_url, params: {format: 'json'}
    end
    it "will return the major version of the api software" do
      expect(json.keys.include?(:major)).to be true
    end
    it "will return the minor version of the api software" do
      expect(json.keys.include?(:minor)).to be true
    end
    it "will return the patch version of the api software" do
      expect(json.keys.include?(:patch)).to be true
    end
    it "will return the pre_release version of the api software" do
      expect(json.keys.include?(:pre_release)).to be true
    end
    it "will return the commit of the api software" do
      expect(json.keys.include?(:commit_sha)).to be true
    end
    it "will return the tag of the api software" do
      expect(json.keys.include?(:tag)).to be true
    end
    it "will return the delta of the api software" do
      expect(json.keys.include?(:delta)).to be true
    end
  end
end
# rubocop:enable Metrics/BlockLength
