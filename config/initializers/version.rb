# rubocop:disable Security/YAMLLoad
VERSION_CONFIG = YAML.load(ERB.new(File.read(File.expand_path('../../version.yml', __FILE__))).result)
VERSION_CONFIG.merge! VERSION_CONFIG.fetch(Rails.env, {})
VERSION_CONFIG.deep_symbolize_keys!
# rubocop:enable Security/YAMLLoad
