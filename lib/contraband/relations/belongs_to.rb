module Contraband
  module Relations
    class BelongsTo < Base

      def foreign_key
        @foreign_key ||= (options[:foreign_key] || "#{name}_id").to_sym
      end

      def create_getter(method_name, foreign_key, generated_methods)
        generated_methods.module_eval do
          define_method(method_name) do
            find_or_defer send(foreign_key)
          end
        end
      end

      def create_foreign_key_getter(foreign_key, generated_methods)
        generated_methods.module_eval do
          define_method(foreign_key) do
            resource.send(foreign_key)
          end
        end
      end
    end
  end
end