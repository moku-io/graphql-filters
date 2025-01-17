module GraphQL
  module Filters
    module Filterable
      extend ActiveSupport::Concern

      # We need the two inner_type chunks of code because type.list? is true if any of the types in the of_type chain
      #   is a list, but type.unwrap returns the raw type. I want the filter to be based on the of_type of the list,
      #   which could be the unwrapped type, but it could also be a non nullable version of that type. The non
      #   nullability is relevant.

      included do
        raise 'You can only apply a filter to a list field' unless filtered_type.list?

        unless defined?(SearchObject::Base) && include?(SearchObject::Base)
          raise 'If you don\'t use SearchObject, you must *prepend* Filterable, not *include* it.'
        end

        inner_type = filtered_type
        inner_type = inner_type.of_type until inner_type.kind == GraphQL::TypeKinds::LIST
        inner_type = inner_type.of_type

        option :filter, type: inner_type.comparison_input_type do |scope, filter|
          filter.call scope
        end
      end

      prepended do
        raise 'You can only apply a filter to a list field' unless filtered_type.list?

        inner_type = filtered_type
        inner_type = inner_type.of_type while inner_type.kind == GraphQL::TypeKinds::LIST
        inner_type = inner_type.of_type

        argument :filter, inner_type.comparison_input_type, required: false

        # Using the `def` raw here would redefine the method on the class that prepended the module, insted of inserting
        #   it in the ancestor chain.
        Module.new do
          def resolve filter: nil, **kwargs
            filter ? filter.call(super(**kwargs)) : super(**kwargs)
          end
        end
          .tap { prepend _1 }
      end
    end
  end
end
