module Contraband
  module Errors

    ##
    # Raised when the model class of an importer cannot be detected.
    class UninferableModel < ContrabandError

      ##
      # Create the new error.
      #
      # @example Create the error.
      #     UninferableModel.new(TwitterImporter::Status)
      #
      # @param [Class] klass
      #   The importer class.
      def initialize(klass)
        super(
          compose_message(
            'uninferable_model',
            { klass: klass.name}
          )
        )
      end
    end # UninferableModel
  end # Errors
end # Contraband