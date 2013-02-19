module Contraband
  module Mongoid
    module Sourceful
      extend ActiveSupport::Concern

      included do
        index({ 'sources._id' => 1, 'sources.service' => 1 })

        embeds_many :sources, as: :sourceful, cascade_callbacks: true

        scope :by_source, ->(service) { where('sources.service' => service) }

        before_validation -> { sources.uniq! }

        validate :validate_uniqueness_of_sources
      end

      module ClassMethods

        ##
        # Attempts to find and return the `Document` matching the provided
        # `source_id` and `service`. If none is found, a new `Document` is
        # initialized with the source and returned.
        #
        # @example Find or initialize the performer referenced by Eventful.
        #     Performer.find_or_initialize_by_source_id_and_service('P0-001-000001033-4', :eventful)
        #
        # @param [String] source_id
        #   The ID referencing the service's version of the `Document`.
        #
        # @param [Symbol] service
        #   The name of the service.
        #
        # @return [Document]
        #   The found or initialized `Document`.
        def find_or_initialize_by_source_id_and_service(source_id, service)
          sourceful = where('sources._id' => source_id, 'sources.service' => service).first
          unless sourceful
            sourceful = new
            sourceful.sources.build do |source|
              source._id = source_id
              source.service = service
            end
          end
          sourceful
        end
      end # ClassMethods

      def can_assign?(service, attribute)
        priorities = sources.select { |source|
          source.service == service || source.tracked_fields.include?(attribute.to_s)
        }.collect { |source|
          [source.service, source.importer_class.priority_of(attribute)]
        }.flatten

        unless priorities.include?(service)
          priorities << service
          priorities << self.class.importer_class(service).priority_of(attribute)
        end

        return true if priorities.empty?
        Hash[*priorities.reverse].min.last == service
      end

      def source_by_name(name)
        sources.where(service: name).first
      end

      ##
      # Detects if the `Document` has a source for the provided service.
      #
      # @example Find if the document references a record from Last.fm.
      #     performer.has_source?(:lastfm)
      #
      # @param [Symbol] service
      #   The name of the service.
      #
      # @return [true, false]
      #   `true` if the `Document` references the provided service,
      #   `false` otherwise.
      def has_source?(service)
        !source_by_name(service).nil?
      end

      def add_source(service, id)
        source = if has_source?(service)
          source_by_name(service)
        else
          sources.build(service: service)
        end
        source.id = id
        unless source.id.present?
          raise ArgumentError, 'A source identifier is required when adding new sources.'
        end
        source
      end

      def save_with(service, source_id = nil)
        touch_source(service, source_id) && save
      end

      ##
      # @return [Array<Source>]
      #   Sources attached to the model.
      def tracked_sources
        sources.collect(&:service)
      end

      ##
      # @example Find the field sources for a specific source.
      #     venue.tracked_fields_by_source(:facebook)
      #     # => [:cover_photo, :description, :location]
      #
      # @return [Array<Symbol>]
      #   Fields tracked by the source.
      def tracked_fields_by_source(name)
        source_by_name(name).tracked_fields.collect(&:to_sym)
      end

      ##
      # @example Find the field sources for an event.
      #     event.field_sources
      #     # => { lastfm: [:name, :description], eventful: [:pricing]  }
      #
      # @return [{ Symbol => Array<Symbol> }]
      #   A hash of sources and the fields they track.
      def field_sources
        Hash.new { |h, k| h[k] = [] }.tap do |hash|
          tracked_sources.each do |source|
            hash[source] = tracked_fields_by_source(source)
          end
        end
      end

      def trackable_changes
        changes.collect do |field, change|
          field if field != '_id' && change.last.present?
        end.compact
      end

      protected

      def validate_uniqueness_of_sources
        sources.each do |source|
          existing = self.class.where('sources._id' => source.id, 'sources.service' => source.service).first

          if existing && existing != self
            return errors[:sources] << 'is invalid'
          end
        end
      end

      private

      def track_source_changes(source)
        return unless changed?
        sources.each(&:untrack_changed_fields)
        source.track_changed_fields
      end

      def touch_source(service, source_id = nil)
        source = if has_source?(service)
          source_by_name(service)
        else
          add_source(service, source_id)
        end

        track_source_changes(source)
        source.touch(:updated_at) unless new_record?
        true
      end
    end # Sourceful
  end # Mongoid
end # Contraband