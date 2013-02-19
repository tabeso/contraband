module Contraband
  module Mongoid
    module DeferredImport
      extend ActiveSupport::Concern

      included do
        field :processor,   type: String
        field :resource_id, type: String
        field :data,        type: Hash, default: {}

        index({ processor: 1, resource_id: 1 })

        validates :processor,   presence: true
        validates :resource_id, presence: { unless: :data? }
        validates :data,        presence: { unless: :resource_id? }

        after_create :enqueue
      end

      module ClassMethods

        def import(processor, id, data = nil)
          find_or_create_by(processor: processor, resource_id: id) do |job|
            job.data = data
          end
        end
      end # ClassMethods

      def import
        processor.import(to_resource) && destroy
      end

      def processor
        read_attribute(:processor).constantize
      end

      def processor=(klass)
        write_attribute(:processor, klass.to_s)
      end

      def to_resource
        if data?
          processor.instantiate(data)
        else
          processor.find(resource_id)
        end
      end

      protected

      def enqueue
        Contraband.backgrounder.perform_async(self)
      end
    end # DeferredImport
  end # Mongoid
end # Contraband