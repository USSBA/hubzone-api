require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Version, type: :model do
  VERSION_CONFIG[:hubzone_api_version] = {
    major: 100,
    minor: 50,
    patch: 1000,
    pre_release: 'zeta'
  }

  context 'with a tagged version (vX.Y.Z) deployed' do
    let!(:version) { described_class.new('v6.5.4-omega-0-g1234abc') }

    it 'will recognize the tagged major version' do
      expect(version.major).to eq(6)
    end

    it 'will recognize the tagged minor version' do
      expect(version.minor).to eq(5)
    end

    it 'will recognize the tagged patch version' do
      expect(version.patch).to eq(4)
    end

    it 'will recognize the tagged pre_release version' do
      expect(version.pre_release).to eq('omega')
    end

    it 'will recognize the latest tag' do
      expect(version.tag).to eq('v6.5.4-omega')
    end
  end

  context 'with a tagged version (X.Y.Z) deployed' do
    let!(:version) { described_class.new('9.8.7-iota-0-g1234abc') }

    it 'will recognize the tagged major version' do
      expect(version.major).to eq(9)
    end

    it 'will recognize the tagged minor version' do
      expect(version.minor).to eq(8)
    end

    it 'will recognize the tagged patch version' do
      expect(version.patch).to eq(7)
    end

    it 'will recognize the tagged pre_release version' do
      expect(version.pre_release).to eq('iota')
    end

    it 'will recognize the latest tag' do
      expect(version.tag).to eq('9.8.7-iota')
    end
  end

  context 'with a generic tag deployed' do
    let!(:version) { described_class.new('project-sprint-99-0-g1234abc') }

    it 'will recognize the hard-coded configured major version' do
      expect(version.major).to eq(100)
    end

    it 'will recognize the hard-coded configured minor version' do
      expect(version.minor).to eq(50)
    end

    it 'will recognize the hard-coded configured patch version' do
      expect(version.patch).to eq(1000)
    end

    it 'will recognize the hard-coded configured pre_release version' do
      expect(version.pre_release).to eq('zeta')
    end

    it 'will recognize the latest tag' do
      expect(version.tag).to eq('project-sprint-99')
    end

    it 'will be released, i.e., the commit is on the tag' do
      expect(version).to be_released
    end
  end

  context 'with a generic commit deployed' do
    let!(:version) { described_class.new('project-sprint-99-55-g1234abc') }

    it 'will recognize the hard-coded configured major version' do
      expect(version.major).to eq(100)
    end

    it 'will recognize the hard-coded configured minor version' do
      expect(version.minor).to eq(50)
    end

    it 'will recognize the hard-coded configured patch version' do
      expect(version.patch).to eq(1000)
    end

    it 'will recognize the hard-coded configured pre_release version' do
      expect(version.pre_release).to eq('zeta')
    end

    it 'will recognize the latest tag' do
      expect(version.tag).to eq('project-sprint-99')
    end

    it 'will recognize the commit delta from the latest tag' do
      expect(version.delta).to eq(55)
    end

    it 'will not be released, i.e., commits have been made since the tag' do
      expect(version).not_to be_released
    end
  end
end
# rubocop:enable Metrics/BlockLength
