require_relative 'base_comparison_input_type'

module GraphQL
  module Filters
    module InputTypes
      class BaseScalarComparisonInputType
        include CachedClass

        resolve_cache_miss do |value_type, klass|
          klass.new BaseComparisonInputType do
            graphql_name "#{value_type.graphql_name}ComparisonInput"

            one_of

            argument :constant,
                     Types::Boolean,
                     prepare: lambda { |value, _context|
                       lambda { |scope, _column_name|
                         if value
                           scope.all
                         else
                           scope.where false
                         end
                       }
                     }
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

            def prepare
              values.sole
            end
          end
        end
      end
    end
  end
end
