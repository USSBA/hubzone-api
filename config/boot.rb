ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

require 'rails/commands/server'

module Rails
  # Created by Rails
  class Server
    # rubocop:disable Style/Alias
    alias :default_options_bk :default_options
    def default_options
      default_options_bk.merge!(Host: '0.0.0.0')
    end
  end
end
