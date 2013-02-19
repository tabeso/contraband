module Contraband
  module Workers
    ##
    # Based on https://github.com/lardawge/carrierwave_backgrounder
    class Base < Struct.new(:id, :attempts)

      MAX_ATTEMPTS = 25

      ##
      # Same exact formula used by Sidekiq when delaying failed jobs.
      DELAY = proc { |count| (count ** 4) + 15 + (rand(30) * (count + 1)) }

      def self.perform(*args)
        new(*args).perform
      end

      def perform(*args)
        set_args(*args) if args.present?
        job = DeferredImport.find(*args)
        delay unless job.import
      end

      private

      def set_args(id, attempt = 0)
        self.id, self.attempts = id, attempt
      end

      def delay
        if attempt < MAX
          Contraband.backgrounder.perform_in(DELAY.call(attempts), id, attempt + 1)
        else
          Contraband.logger.info "Dropping DeferredImport #{id}. Too many failed attempts."
        end
      end
    end # Base
  end # Workers
end # Contraband