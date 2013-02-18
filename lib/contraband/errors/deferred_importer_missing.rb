module Contraband
  module Errors

    ##
    # Raised when a `DeferredImport` model is not defined.
    class DeferredImporterMissing < ContrabandError

      ##
      # Create the new error.
      #
      # @example Create the error.
      #     DeferredImporterMissing.new
      def initialize
        super(
          compose_message(
            'deferred_importer_missing'
          )
        )
      end
    end # DeferredImporterMissing
  end # Errors
end # Contraband