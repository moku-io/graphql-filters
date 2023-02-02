require_relative 'comparison_input_type'

module GraphQL
  module Filters
    module InputTypes
      class FieldsComparisonInputType
        include CachedClass

        resolve_cache_miss do |object_type, klass|
          klass.new Filters.base_input_object_class do
            graphql_name "#{object_type.graphql_name}ComparisonInput"

            object_type.fields.each_value do |field_object|
              type = field_object.type

              type = type.of_type while type.kind == GraphQL::TypeKinds::NON_NULL

              argument field_object.name,
                       ComparisonInputType[type],
                       required: false,
                       prepare: lambda { |field_comparator, _context|
                         lambda { |scope|
                           field_comparator.call(scope, field_object.name)
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
