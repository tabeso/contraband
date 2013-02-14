module Contraband
  module RSpecMatchers

    def have_attribute(*attributes)
      HaveAttributeMatcher.new(*attributes)
    end

    def have_attributes(*attributes)
      have_attribute(*attributes)
    end

    class HaveAttributeMatcher

      def initialize(*attributes)
        @attributes = attributes.collect(&:to_sym)
      end

      def with_priority(priority)
        @expected_priority = priority
        self
      end

      def as(key)
        @expected_alias = key
        self
      end

      def matches?(actual)
        find_failing_attributes(actual, :reject).empty?
      end
      alias :== :matches?

      def does_not_match?(actual)
        find_failing_attributes(actual, :select).empty?
      end

      def failure_message_for_should
        "expected #{@actual.inspect} to have attribute#{@attributes.count > 1 ? 's' : ''} #{@attributes.collect(&:inspect).join(', ')}#{message_as_alias}#{message_with_priority}"
      end

      def failure_message_for_should_not
        failure_message_for_should.sub(/to have attribute/, 'not to have attribute')
      end

      def description
        "has attribute#{@attributes.count > 1 ? 's' : ''} #{@attributes.collect(&:inspect).join(', ')}#{message_as_alias}#{message_with_priority}"
      end

      private

      def find_failing_attributes(actual, filter_method)
        @actual = actual.is_a?(Class) ? actual : actual.class
        @failing_attributes = @attributes.__send__(filter_method) do |name|
          @actual.has_attribute?(name) && matches_priority?(name) && matches_alias?(name)
        end
      end

      def matches_priority?(name)
        return true unless @expected_priority
        @actual.attributes[name].try(:priority) == @expected_priority
      end

      def matches_alias?(name)
        return true unless @expected_alias
        @actual.attributes[name].try(:alias) == @expected_alias
      end

      def message_with_priority
        @expected_priority ? " with priority #{@expected_priority}" : ''
      end

      def message_as_alias
        @expected_alias ? " as #{@expected_alias.inspect}" : ''
      end
    end # HaveAttributeMatcher
  end # RSpecMatchers

  module ImporterExampleGroup
    include RSpecMatchers
    extend ActiveSupport::Concern

    included do
      metadata[:type] = :importer
    end
  end # ImporterExampleGroup

  RSpec.configure do |config|
    config.include ImporterExampleGroup, example_group: { file_path: %r{spec/importers} }, type: :importer
  end
end # Contraband