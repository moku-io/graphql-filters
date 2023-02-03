require_relative 'base_scalar_comparison_input_type'

module GraphQL
  module Filters
    module InputTypes
      class NumericComparisonInputType
        include CachedClass

        resolve_cache_miss do |value_type, klass|
          klass.new BaseScalarComparisonInputType[value_type] do
            argument :greater_than,
                     value_type,
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         scope.where("#{column_name} > ?", value)
                       }
                     }
            argument :greater_than_or_equals_to,
                     value_type,
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         scope.where("#{column_name} >= ?", value)
                       }
                     }
            argument :less_than,
                     value_type,
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         scope.where("#{column_name} < ?", value)
                       }
                     }
            argument :less_than_or_equals_to,
                     value_type,
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         scope.where("#{column_name} <= ?", value)
                       }
                     }
          end
        end
      end
    end
  end
end
