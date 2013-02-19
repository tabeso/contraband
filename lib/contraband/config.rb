module Contraband
  class Config

    BACKGROUNDERS = {
      sidekiq: Backgrounders::Sidekiq
    }

    delegate :logger=, to: ::Contraband
    delegate :logger,  to: ::Contraband

    ##
    # @example Configure to use Sidekiq with options.
    #     Contraband.backgrounder :sidekiq, queue: :imports
    def backgrounder(klass = nil, options = {})
      return @backgrounder unless klass.present?
      @backgrounder = (BACKGROUNDERS[klass] || klass).new(options)
    end

    def backgrounder?
      !!@backgrounder
    end
  end # Config
end # Contraband