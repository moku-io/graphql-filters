require 'active_support/core_ext/hash/reverse_merge'
require 'graphql/type_kinds'

module GraphQL
  module Filters
    module InputTypes
      class BaseScalarComparisonInputType
        include CachedClass

        resolve_cache_miss do |value_type, klass|
          filter_type = (value_type.kind == GraphQL::TypeKinds::SCALAR) ? value_type : value_type.filter_type

          klass.new Filters.base_input_object_class do
            def self.argument *args, **kwargs, &block
              kwargs.reverse_merge! required: false
              super(*args, **kwargs, &block)
            end

            graphql_name "#{filter_type.graphql_name}ComparisonInput"

            one_of

            argument :eq,
                     filter_type,
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         scope.where(column_name => value)
                       }
                     }
            argument :not_eq,
                     filter_type,
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         scope.where.not(column_name => value)
                       }
                     }
            argument :in,
                     [filter_type],
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         scope.where(column_name => value)
                       }
                     }
            argument :not_in,
                     [filter_type],
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
