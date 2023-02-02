require_relative 'comparison_input_type'

module GraphQL
  module Filters
    module InputTypes
      class ComplexFilterInputType
        include CachedClass

        resolve_cache_miss do |value_type, klass|
          next ComplexFilterInputType[value_type.of_type] if value_type.respond_to? :of_type

          klass.new Filters.base_input_object_class do
            graphql_name "#{value_type.graphql_name}ComplexFilterInput"

            one_of
            argument :and,
                     [self],
                     required: false,
                     prepare: lambda { |and_arg, _context|
                       lambda { |scope|
                         and_arg.reduce scope do |acc, val|
                           val.call acc
                         end
                       }
                     }
            argument :or,
                     [self],
                     required: false,
                     prepare: lambda { |or_arg, _context|
                       lambda { |scope|
                         or_arg.reduce scope.none do |acc, val|
                           acc.or val.call(scope)
                         end
                       }
                     }
            argument :not,
                     self,
                     required: false,
                     prepare: lambda { |not_arg, _context|
                       lambda { |scope|
                         scope.and(not_arg.call(scope).invert_where)
                       }
                     }
            argument :fields, ComparisonInputType[value_type], required: false

            def prepare
              values.sole
            end
          end
        end
      end
    end
  end
end
