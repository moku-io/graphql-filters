require_relative 'base_list_comparison_input_type'

module GraphQL
  module Filters
    module InputTypes
      class ListScalarComparisonInputType
        include CachedClass

        resolve_cache_miss do |value_type, klass|
          klass.new BaseListComparisonInputType[value_type] do
            argument :equals,
                     value_type,
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         scope.where(column_name => value)
                       }
                     }
            argument :not_equals,
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
                     value_type,
                     prepare: lambda { |_value, _context|
                       lambda { |_scope, _column_name|
                         table = scope.table[column_name]
                         attribute = scope.predicate_builder.build_bind_attribute column_name, value
                         scope.where table.contained(attribute)
                       }
                     }
            argument :not_subset_of,
                     value_type,
                     prepare: lambda { |_value, _context|
                       lambda { |_scope, _column_name|
                         table = scope.table[column_name]
                         attribute = scope.predicate_builder.build_bind_attribute column_name, value
                         scope.where.not table.contained(attribute)
                       }
                     }
            argument :superset_of,
                     value_type,
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         table = scope.table[column_name]
                         attribute = scope.predicate_builder.build_bind_attribute column_name, value
                         scope.where table.contains(attribute)
                       }
                     }
            argument :not_superset_of,
                     value_type,
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         table = scope.table[column_name]
                         attribute = scope.predicate_builder.build_bind_attribute column_name, value
                         scope.where.not table.contains(attribute)
                       }
                     }
          end
        end
      end
    end
  end
end
