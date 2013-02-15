module Contraband
  module Errors

    ##
    # Raised when the importer for a model cannot be detected.
    class UninferableImporter < ContrabandError

      ##
      # Create the new error.
      #
      # @example Create the error.
      #   UninferableImporter.new(Status)
      #
      # @param [Symbol] service
      #   The service of the missing importer.
      #
      # @param [Class] klass
      #   The model class.
      def initialize(service, klass)
        super(
          compose_message(
            'uninferable_importer',
            {
              service: service.inspect,
              klass: klass.name,
              expected: expected_class(service, klass)
            }
          )
        )
      end

      private

      def expected_class(service, klass)
        "#{service.to_s.camelize}Importer::#{klass}"
      end
    end # UninferableImporter
  end # Errors
end # Contraband