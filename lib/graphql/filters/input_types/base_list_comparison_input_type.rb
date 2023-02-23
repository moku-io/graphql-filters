require_relative 'base_comparison_input_type'

module GraphQL
  module Filters
    module InputTypes
      class BaseListComparisonInputType
        include CachedClass

        resolve_cache_miss do |value_type, klass|
          klass.new BaseComparisonInputType do
            graphql_name "#{value_type.unwrap.graphql_name}ListComparisonInput"

            one_of

            def prepare
              values.sole
            end
          end
        end
      end
    end
  end
end
