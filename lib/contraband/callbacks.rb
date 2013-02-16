module Contraband
  module Callbacks
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Callbacks

      define_model_callbacks :import
    end
  end # Callbacks
end # Contraband