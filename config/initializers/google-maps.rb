MAP_CONFIG = YAML.load(ERB.new(File.read(File.expand_path('../../map.yml', __FILE__))).result)
MAP_CONFIG.merge! MAP_CONFIG.fetch(Rails.env, {})
MAP_CONFIG.symbolize_keys!
