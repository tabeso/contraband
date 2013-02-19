module Contraband
  module Sourceful
    extend ActiveSupport::Concern

    included do
      if defined?(::Mongoid) && include?(::Mongoid::Document)
        include Mongoid::Sourceful
      else
        warn <<-MSG.strip_heredoc
          Currently, Contraband only supports Mongoid. If you'd like to see
          support for your ORM of choice, please open anissue at
          https://github.com/tabeso/contraband.
        MSG
      end
    end
  end
end # Contraband