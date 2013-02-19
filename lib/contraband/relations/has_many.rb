module Contraband
  module Relations
    class HasMany < Base

      def model_class
        @model_class ||= name.to_s.singularize.constantize
      end

      def foreign_key
        @foreign_key ||= (options[:foreign_key] || "#{name.to_s.singularize}_ids").to_sym
      end

      def create_getter(generated_methods)
        generated_methods.module_eval do
          define_method(name) do
            send(foreign_key).map { |id| find_or_defer(id) }
          end
        end
      end

      def create_ids_getter(generated_methods)
        generated_methods.module_eval do
          define_method(foreign_key) do
            resource.send(foreign_key).compact.uniq
          end
        end
      end
    end # HasMany
  end # Relations
end # Contraband