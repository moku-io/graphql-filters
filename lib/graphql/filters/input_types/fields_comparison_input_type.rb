require_relative 'base_comparison_input_type'

module GraphQL
  module Filters
    module InputTypes
      class FieldsComparisonInputType
        include CachedClass

        resolve_cache_miss do |object_type, klass|
          klass.new BaseComparisonInputType do
            graphql_name "#{object_type.graphql_name}ComparisonInput"

            object_type.fields.each_value do |field_object|
              next unless field_object.filter_options.enabled

              type = field_object.type

              argument field_object.name,
                       type.comparison_input_type,
                       required: false,
                       prepare: lambda { |field_comparator, _context|
                         lambda { |scope|
                           field_comparator.call(scope, field_object.filter_options.column_name)
                         }
                       }
            end

            def prepare
              lambda do |scope|
                values.reduce scope do |acc, val|
                  val.call acc
                end
              end
            end
          end
        end
      end
    end
  end
end
