require 'contraband/orms/mongoid'

require 'mongoid'
Mongoid.load!(File.join(File.dirname(__FILE__), '..', 'config', 'mongoid.yml'), :test)

require 'mongoid-rspec'
require 'database_cleaner'

RSpec.configure do |config|
  config.include Mongoid::Matchers

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end