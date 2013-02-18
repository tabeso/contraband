module Contraband
  module Errors

    ##
    # Raised when the importer for a model cannot be detected.
    class ImportDeferred < ContrabandError

      ##
      # Create the new error.
      #
      # @example Create the error.
      #     ImportDeferred.new(Status)
      #
      # @param [Class] klass
      #   The importer class.
      def initialize(klass)
        super(
          compose_message(
            'import_deferred',
            {
              klass: klass.name
            }
          )
        )
      end
    end # ImportDeferred
  end # Errors
end # Contraband