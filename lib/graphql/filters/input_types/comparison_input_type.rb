require_relative 'fields_comparison_input_type'
require_relative 'list_scalar_comparison_input_type'
require_relative 'string_comparison_input_type'
require_relative 'numeric_comparison_input_type'
require_relative 'base_scalar_comparison_input_type'

module GraphQL
  module Filters
    module InputTypes
      class ComparisonInputType
        include CachedClass

        resolve_cache_miss do |value_type|
          value_type = value_type.of_type while value_type.kind == GraphQL::TypeKinds::NON_NULL

          if value_type.kind == GraphQL::TypeKinds::LIST
            value_type = value_type.of_type while value_type.respond_to? :of_type

            if value_type.kind == GraphQL::TypeKinds::OBJECT
              FieldsComparisonInputType[value_type]
            else
              ListScalarComparisonInputType[value_type]
            end
          elsif value_type.kind == GraphQL::TypeKinds::OBJECT
            FieldsComparisonInputType[value_type]
          elsif value_type == GraphQL::Types::String
            StringComparisonInputType
          elsif [GraphQL::Types::Int, GraphQL::Types::Float].include? value_type
            NumericComparisonInputType[value_type]
          else
            BaseScalarComparisonInputType[value_type]
          end
        end
      end
    end
  end
end
