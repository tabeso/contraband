require 'bundler/setup'

unless ENV['CI']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'sidekiq'

require 'contraband'
require 'contraband/test/rspec_integration'

Contraband.configure do |config|
  config.backgrounder :sidekiq
end

require 'active_support/dependencies'

# Simulate a Rails app's autoloading of models and importers
DUMMY_ROOT = File.join(File.dirname(__FILE__), 'dummy', 'app')
%w(models importers).each do |path|
  ActiveSupport::Dependencies.autoload_paths << File.join(DUMMY_ROOT, path)
end

RSpec.configure do |config|
  config.include Contraband::RSpecMatchers

  unless ENV['CI']
    config.filter_run focus: true
  end

  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.order = 'random'
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
