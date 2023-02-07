require_relative 'base_list_comparison_input_type'

module GraphQL
  module Filters
    module InputTypes
      class ListScalarComparisonInputType
        include CachedClass

        resolve_cache_miss do |value_type, klass|
          klass.new BaseListComparisonInputType[value_type] do
            argument :eq,
                     value_type,
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         scope.where(column_name => value)
                       }
                     }
            argument :not_eq,
                     value_type,
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         scope.where.not(column_name => value)
                       }
                     }
            argument :in,
                     [value_type],
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         scope.where(column_name => value)
                       }
                     }
            argument :not_in,
                     [value_type],
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         scope.where.not(column_name => value)
                       }
                     }
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
