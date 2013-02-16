require 'hashie'

module Contraband
  class Importer
    include Attributes
    include Callbacks
    include Processing

    ##
    # The regexp for finding the service and model from a class name.
    IMPORTER_PATTERN = /^(?<service>.+)Importer::(?<model>.+)$/

    ##
    # By default, attempts to infer the model class of the importer from the
    # class name. Importers should either follow the naming convention
    # `<Service>Importer::<Model>` or override this method to return the
    # correct model class.
    #
    # @example Getting the service
    #     ImdbImporter::Actor.model_class
    #     # => Actor
    #
    # @return [Class]
    #   The model handled by the importer.
    def self.model_class
      name.match(IMPORTER_PATTERN)[:model].constantize
    rescue NoMethodError, NameError
      raise Errors::UninferableModel, self
    end

    ##
    # By default, attempts to infer the service of the importer from the class
    # name. Importers should either follow the naming convention
    # `<Service>Importer::<Model>` or override this method to return the
    # correct service.
    #
    # @example Getting the service
    #     LastfmImporter::Artist.service
    #     # => :lastfm
    #
    # @return [Symbol]
    #   The service handled by the importer.
    def self.service
      name.match(IMPORTER_PATTERN)[:service].underscore.to_sym
    rescue NoMethodError, NameError
      raise Errors::UninferableService, self
    end

    ##
    # By default, expects a `Hash` of data. The provided data is wrapped in a
    # `Hashie::Mash` to allow accessing attributes as an object. Override this
    # method for service-specific functionality.
    #
    # @example Instantiate some data
    #     page = FacebookImporter::Post.instantiate(
    #       name: 'lik dis if u cry evertiem'
    #     )
    #     # => #<Hashie::Mash ...>
    #
    #     page.name
    #     # => 'lik dis if u cry evertiem'
    #
    # @param [Hash] data
    #   Raw data to instantiate.
    #
    # @return [Object]
    #   The instantiated data.
    def self.instantiate(data)
      Hashie::Mash.new(data)
    end

    ##
    # By default, raises a `FinderNotImplemented` error. Override with custom
    # logic for locating resources by a provided identifier.
    #
    # @param [String, Integer] id
    #   Identifier of the resource to fetch.
    #
    # @return [Object]
    #   The retrieved resource.
    def self.find(id)
      raise Errors::FinderNotImplemented, self
    end

    attr_reader :resource

    def initialize(resource)
      @resource = resource
    end

    def logger
      Contraband.logger
    end

    def model_class
     self.class.model_class
    end

    def service
      self.class.service
    end
  end # Importer
end # Contraband