module Contraband
  module Processing
    extend ActiveSupport::Concern

    module ClassMethods

      def import(resource)
        new(resource).import
      end

      def import_async(id, data = {})
        defined?(DeferredImport) or raise Errors::DeferredImporterMissing
        DeferredImport.import(self, id, data)
      end
    end # ClassMethods

    def import
      run_callbacks :import do
        process_attributes
      end

      model.changed? ? save : true
    end

    def model
      @model ||= model_class.find_or_initialize_by_source_id_and_service(
        id, service
      )
    end

    protected

    def process_attributes
      assignable_attributes.each do |attribute|
        model.send(:"#{attribute}=", send(attribute))
      end
    end

    def save
      model.respond_to?(:save_with) ? model.save_with(service) : model.save
    end

    def defer
      raise Errors::ImportDeferred, self
    end
  end # Processing
end # Contraband