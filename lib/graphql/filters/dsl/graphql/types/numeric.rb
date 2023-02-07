require 'active_support/concern'
require_relative '../../../input_types/numeric_comparison_input_type'

monkey_patch = Module.new do
  extend ActiveSupport::Concern

  class_methods do
  protected

    def get_comparison_input_type(*)
      GraphQL::Filters::InputTypes::NumericComparisonInputType
    end
  end
end

GraphQL::Types::Int.prepend monkey_patch
GraphQL::Types::BigInt.prepend monkey_patch
GraphQL::Types::Float.prepend monkey_patch
GraphQL::Types::ISO8601Date.prepend monkey_patch
GraphQL::Types::ISO8601DateTime.prepend monkey_patch
