module Contraband
  module Relations
    class Base

      attr_reader :name

      attr_reader :options

      attr_reader :service

      def initialize(importer, name, options = {})
        @name = name.to_sym
        @options = options
        @service = (options[:service] || importer.service).to_sym
      end

      def find_or_defer(id, data = {})
        related = model_class.find_or_initialize_by_source_id_and_service(
          id, service
        )
        import_async_and_defer(id, data) unless related.persisted?
        related
      end

      def import_async_and_defer(id, data = {})
        importer_class.import_async(id, data)
        raise Errors::Deferred, importer_class
      end

      def importer_class
        model_class.importer_class(service)
      end

      def create_accessors(generated_methods)
        create_getter(name, foreign_key, generated_methods)
        create_foreign_key_getter(foreign_key, generated_methods)
      end
    end # Base
  end # Relations
end # Contraband