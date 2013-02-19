module Contraband
  module Mongoid
    ##
    # Keeps track of imported sources for documents as well as where fields
    # came from.
    module Source
      extend ActiveSupport::Concern

      included do
        include ::Mongoid::Timestamps

        field :_id,            type: String
        field :service,        type: Symbol
        field :tracked_fields, type: Array, default: []

        embedded_in :sourceful, polymorphic: true
      end

      ##
      # Removes changed fields of `sourceful` from the source's
      # `tracked_fields`. Used by {#track_changed_fields} to ensure other
      # sources are not conflicting.
      def untrack_changed_fields
        tracked_fields.delete_if { |f| sourceful.changed.include?(f) }
      end

      ##
      # Adds changed fields of `sourceful` to the source's `tracked_fields`.
      def track_changed_fields
        sourceful.sources.each(&:untrack_changed_fields)
        self.tracked_fields += sourceful.trackable_changes
      end

      def importer_class
        sourceful.class.importer_class(service)
      end
    end # Source
  end # Mongoid
end # Contraband