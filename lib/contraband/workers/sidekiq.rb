module Contraband
  module Workers
    class Sidekiq < Base
      include ::Sidekiq::Worker
    end
  end # Workers
end # Contraband