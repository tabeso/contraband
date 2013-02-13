module Contraband
  module Errors

    # Raised when the finder of an importer is call but has not been overridden.
    class FinderNotImplemented < ContrabandError

      ##
      # Create the new error.
      #
      # @example Create the error.
      #   FinderNotImplemented.new(TwitterImporter::Status)
      #
      # @param [Class] klass
      #   The importer class.
      def initialize(klass)
        super(
          compose_message(
            'finder_not_implemented',
            { klass: klass.name}
          )
        )
      end
    end # UninferableService
  end # Errors
end # Contraband