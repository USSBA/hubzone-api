# Provide version information for the system.
class Version
  attr_reader :release

  def initialize(git_description = git_describe)
    @git_description = git_description
    @release ||= acquire_release_information
  end

  def git_describe
    desc = IO.popen(['git', 'describe', '--long'], err: File::NULL).read
    desc = File.read(Rails.root.join("REVISION")) if desc.nil? || desc.blank?
    desc
  end

  def major
    release[:major].to_i
  end

  def minor
    release[:minor].to_i
  end

  def patch
    release[:patch].to_i
  end

  def pre_release
    release[:pre_release]
  end

  def commit
    release[:commit_sha]
  end

  def tag
    release[:tag]
  end

  def delta
    release[:delta].to_i
  end

  def released?
    delta.zero?
  end

  def to_s
    result = "v#{major}.#{minor}.#{patch}"
    result += "-#{pre_release}" if pre_release.present?
    result += " (#{commit})" if commit.present?
    result
  end

  private def acquire_release_information
    desc_regex = /^(.*)-(\d+)-g([a-f0-9]+)$/
    desc = @git_description
    matches = desc_regex.match desc
    return version_components if matches.nil?

    tag = matches[1]
    delta = matches[2]
    commit_sha = matches[3]
    { tag:         tag,
      delta:       delta,
      commit_sha:  commit_sha }.merge version_components(tag)
  end

  private def non_version_tag?(tag)
    components = /v?(\d+).(\d+).(\d+)-?(.*)/.match tag
    components.nil?
  end

  private def version_components(tag = "")
    components = /v?(\d+).(\d+).(\d+)-?(.*)/.match tag
    components.present? ? parsed_version(components) : config_version
  end

  private def parsed_version(components)
    { major:       components[1],
      minor:       components[2],
      patch:       components[3],
      pre_release: components[4] }
  end

  private def config_version
    { major:       MAP_CONFIG[:hubzone_map_version][:major],
      minor:       MAP_CONFIG[:hubzone_map_version][:minor],
      patch:       MAP_CONFIG[:hubzone_map_version][:patch],
      pre_release: MAP_CONFIG[:hubzone_map_version][:pre_release] }
  end
end
