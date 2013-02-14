require 'active_model'
require 'active_support/core_ext'

require 'contraband/version'
require 'contraband/errors'
require 'contraband/railtie' if defined?(Rails)

# Add English load path by default
I18n.load_path << File.join(File.dirname(__FILE__), 'config', 'locales', 'en.yml')

module Contraband
end # Contraband