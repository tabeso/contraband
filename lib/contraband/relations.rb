require 'contraband/relations/base'
require 'contraband/relations/belongs_to'
require 'contraband/relations/has_many'

module Contraband
  module Relations
    extend ActiveSupport::Concern

    included do
      class_attribute :relations
      self.relations = {}
    end

    module ClassMethods

      def belongs_to(name, options = {})
        add_relation BelongsTo.new(self, name, options)
      end

      def has_many(name, options = {})
        add_relation HasMany.new(self, name, options)
      end

      private

      def add_relation(relation)
        self.relations[relation.name] = relation
        relation.create_accessors(generated_methods)
      end
    end # ClassMethods
  end # Relations
end # Contraband