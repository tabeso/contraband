module Contraband
  module Backgrounders
    class Sidekiq

      attr_reader :options

      def initialize(opts = {})
        @options = opts
        worker_class.sidekiq_options(options) if options.present?
      end

      def perform_async(import)
        worker_class.perform_async(import.id.to_s)
      end

      def perform_in(interval, import)
        worker_class.perform_in(interval, import.id.to_s)
      end
      alias :perform_at :perform_in

      def worker_class
        @worker_class ||= (options.delete(:worker_class) || Workers::Sidekiq)
      end
    end
  end # Backgrounders
end # Contraband