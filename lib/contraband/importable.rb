module Contraband
  ##
  # Importable models should include this module. Provides helper methods for
  # inferring the importer of a service and importing data.
  #
  # @example Import a resource.
  #     Event.import(:facebook, event_data)
  module Importable
    extend ActiveSupport::Concern

    included do
      include Contraband::Sourceful
    end

    module ClassMethods

      ##
      # Infers the importer class to be used by {Contraband#import}
      #
      # @example Get the importer for a specific service.
      #     Product.importer_class(:zappos)
      #     # => ZapposImporter::Product
      #
      # @param [Symbol, String] service
      #   The service of the importer.
      #
      # @return [Class]
      #   The inferred importer class.
      def importer_class(service)
        suffix = respond_to?(:model_name) ? model_name : name
        "#{service.to_s.camelize}Importer::#{suffix}".constantize
      rescue NoMethodError, NameError
        raise Errors::UninferableImporter.new(service, self)
      end

      ##
      # @example Import a resource.
      #     Event.import(:google_calendar, event)
      def import(service, resource)
        Contraband.import(self, service, resource)
      end
    end # ClassMethods
  end # Importable
end # Contraband