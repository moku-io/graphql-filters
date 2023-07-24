require_relative 'base_comparison_input_type'
require_relative 'fields_comparison_input_type'

module GraphQL
  module Filters
    module InputTypes
      class ObjectComparisonInputType
        include CachedClass

        resolve_cache_miss do |value_type, klass|
          klass.new BaseComparisonInputType do
            graphql_name "#{value_type.graphql_name}ComplexFilterInput"

            fields_comparison_input_type = FieldsComparisonInputType[value_type]

            define_singleton_method :fields_comparison_input_type do
              fields_comparison_input_type
            end

            one_of

            argument :constant,
                     Types::Boolean,
                     prepare: lambda { |value, _context|
                       lambda { |scope, _association_name=nil|
                         if value
                           scope.all
                         else
                           scope.none
                         end
                       }
                     }
            argument :and,
                     [self],
                     required: false,
                     prepare: lambda { |and_arg, _context|
                       lambda { |scope, association_name=nil|
                         and_arg.reduce scope do |acc, val|
                           acc.and val.call(scope, association_name)
                         end
                       }
                     }
            argument :or,
                     [self],
                     required: false,
                     prepare: lambda { |or_arg, _context|
                       lambda { |scope, association_name=nil|
                         or_arg.reduce scope.none do |acc, val|
                           acc.or val.call(scope, association_name)
                         end
                       }
                     }
            argument :not,
                     self,
                     required: false,
                     prepare: lambda { |not_arg, _context|
                       lambda { |scope, association_name=nil|
                         scope.and(not_arg.call(scope.unscope(:where), association_name).invert_where)
                       }
                     }
            argument :fields, fields_comparison_input_type, required: false

            def prepare
              values.sole
            end
          end
        end
      end
    end
  end
end
