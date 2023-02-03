require_relative 'base_scalar_comparison_input_type'

module GraphQL
  module Filters
    module InputTypes
      class ListScalarComparisonInputType
        include CachedClass

        resolve_cache_miss do |value_type, klass|
          klass.new BaseScalarComparisonInputType[value_type] do
            graphql_name "#{value_type.graphql_name}ListComparisonInput"

            argument :subset_of,
                     [value_type],
                     prepare: lambda { |_value, _context|
                       lambda { |_scope, _column_name|
                         raise 'Not implemented'
                       }
                     }
            argument :not_subset_of,
                     [value_type],
                     prepare: lambda { |_value, _context|
                       lambda { |_scope, _column_name|
                         raise 'Not implemented'
                       }
                     }
            argument :superset_of,
                     [value_type],
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         scope.where.contains(column_name => value)
                       }
                     }
            argument :not_superset_of,
                     [value_type],
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         scope.and(scope.where.contains(column_name => value).invert_where)
                       }
                     }
          end
        end
      end
    end
  end
end
