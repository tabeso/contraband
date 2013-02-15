module Contraband
  module Errors

    ##
    # Raised when the service of an importer cannot be detected.
    class UninferableService < ContrabandError

      ##
      # Create the new error.
      #
      # @example Create the error.
      #   UninferableService.new(TwitterImporter::Status)
      #
      # @param [Class] klass
      #   The importer class.
      def initialize(klass)
        super(
          compose_message(
            'uninferable_service',
            { klass: klass.name}
          )
        )
      end
    end # UninferableService
  end # Errors
end # Contraband