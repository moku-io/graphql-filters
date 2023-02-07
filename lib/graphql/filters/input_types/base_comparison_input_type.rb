module GraphQL
  module Filters
    module InputTypes
      class BaseComparisonInputType < Filters.base_input_object_class
        def self.argument *args, **kwargs, &block
          kwargs[:required] = false
          super(*args, **kwargs, &block)
        end
      end
    end
  end
end
