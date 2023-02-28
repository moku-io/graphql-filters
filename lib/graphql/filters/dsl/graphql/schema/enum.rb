require 'active_support/concern'
require_relative '../../../input_types/base_scalar_comparison_input_type'

monkey_patch = Module.new do
  extend ActiveSupport::Concern

  class_methods do
  protected

    def get_comparison_input_type(*)
      GraphQL::Filters::InputTypes::BaseScalarComparisonInputType[self]
    end
  end
end

GraphQL::Schema::Enum.prepend monkey_patch
