require 'bundler/setup'

unless ENV['CI']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'contraband'

RSpec.configure do |config|
  unless ENV['CI']
    config.filter_run focus: true
  end

  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.order = 'random'
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
