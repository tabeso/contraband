module Contraband
  ##
  # Stores the alias and priority of an attribute.
  class Attribute < Struct.new(:key, :priority); end

  ##
  # Provides attribute definition helpers as well as priority and assignment
  # checking.
  module Attributes
    extend ActiveSupport::Concern

    module ClassMethods

      ##
      # Defines multiple attributes to be handled by the importer.
      # See {.attribute}.
      #
      # @example Define attributes.
      #     attributes :name, :description, :location, :time_zone, priority: 7
      #
      # @overload attributes(*attrs, options = {})
      #   @param [Array] attrs
      #     Attributes to define.
      #
      #   @param [Hash] options
      #     Options to apply to each defined attribute.
      #
      #   @option options [Integer] :priority
      #     The priority to apply to each defined attribute.
      def attributes(*attrs)
        @attributes ||= {}
        return @attributes if attrs.empty?

        options = attrs.extract_options!
        options[:priority] ||= 1
        options.delete(:as) # prevent silly mistakes

        attrs.each do |attr|
          attribute(attr, options)
        end
      end

      ##
      # Defines an attribute to be handled by the importer. For each attribute
      # that is defined, a getter and assignment checker will be added as an
      # instance method to the importer. By default, getters will delegate to
      # the resource and checkers will delegate to {#can_assign?}.
      #
      # @example Define an attribute.
      #     attribute :event_name, priority: 2, as: :name
      #
      # @param [Symbol] name
      #   The name of the attribute, used by the resource.
      #
      # @param [Hash] options
      #   The options to set on the attribute.
      #
      # @option options [Integer] :priority
      #   The priority of the attribute.
      #
      # @option options [Symbol] :as
      #   The name of the attribute, used by the model.
      def attribute(name, options = {})
        options = options.dup
        options[:priority] ||= 1
        options[:as] ||= name.to_s.gsub(/\?$/, '').to_sym
        add_attribute(name, options)
      end

      def has_attribute?(attr)
        attributes.has_key?(attr) || attributes.values.collect(&:key).include?(attr)
      end

      def priority_of(attr)
        attributes[attr].try(:priority)
      end

      protected

      def add_attribute(name, options)
        attributes[name] = Attribute.new(options[:as], options[:priority])
        create_accessors(name, name)
        create_accessors(name, options[:as]) if name != options[:as]
      end

      def create_accessors(name, method_name)
        create_attribute_getter(name, method_name)
        create_attribute_assignable(name, method_name)
      end

      def create_attribute_getter(name, method_name)
        generated_methods.module_eval do
          define_method(method_name) do
            resource.send(name)
          end
        end
      end

      def create_attribute_assignable(name, method_name)
        generated_methods.module_eval do
          define_method(:"can_assign_#{method_name}?") do
            can_assign?(name)
          end
        end
      end

      def generated_methods
        @generated_methods ||= begin
          mod = Module.new
          include(mod)
          mod
        end
      end
    end # ClassMethods

    def attributes
      self.class.attributes
    end

    def priority_of(attr)
      self.class.priority_of(attr)
    end

    ##
    # Determines whether the provided attribute can be assigned on the model.
    #
    # @return [true, false]
    #   Whether the attribute can be assigned.
    def can_assign?(attr)
      return false unless attributes[attr].present?
      model.respond_to?(:can_assign?) ? model.can_assign?(attr) : true
    end

    ##
    # Determines which attributes can be assigned on the model.
    #
    # @return [Array<Symbol>]
    #   The assignable attributes.
    def assignable_attributes
      attributes.keys.select { |attr| can_assign?(attr) }
    end

    ##
    # By default, attempts to call `resource.id`. Override in cases where
    # resource identifiers are mapped to a different attribute name.
    #
    # @return [String, Integer]
    #   The resource identifier.
    def id
      resource.id
    end
  end # Attributes
end # Contraband