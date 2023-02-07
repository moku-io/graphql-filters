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

            argument :any,
                     value_type.of_type.comparison_input_type,
                     prepare: lambda { |value, _context|
                       lambda {|scope, column_name|
                         scope
                       }
                     }
            argument :all,
                     value_type.of_type.comparison_input_type,
                     prepare: lambda { |value, _context|
                       lambda {|scope, column_name|
                         scope
                       }
                     }
            argument :none,
                     value_type.of_type.comparison_input_type,
                     prepare: lambda { |value, _context|
                       lambda {|scope, column_name|
                         scope
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
