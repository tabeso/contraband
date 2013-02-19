module Contraband
  class Railtie < Rails::Railtie

    config.initializers 'contraband.mongoid' do
      require 'contraband/orms/mongoid' if defined?(::Mongoid)
    end

    config.after_initialize do |app|
      app.config.paths.add 'app/importers', eager_load: true

      if Rails.env.test?
        require 'contraband/test/rspec_integration' if defined?(RSpec) && RSpec.respond_to?(:configure)
      end
    end
  end # Railtie
end # Contraband