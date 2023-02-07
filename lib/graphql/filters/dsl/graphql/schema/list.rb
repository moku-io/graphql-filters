require 'active_support/concern'
require_relative '../../../input_types/base_list_comparison_input_type'
require_relative '../../../input_types/list_scalar_comparison_input_type'

monkey_patch = Module.new do
  extend ActiveSupport::Concern

  def comparison_input_type new_comparison_input_type=nil
    if new_comparison_input_type.present?
      @comparison_input_type = new_comparison_input_type
    else
      @comparison_input_type ||= build_comparison_input_type
    end
  end

protected

  def build_comparison_input_type
    if unwrap.kind == GraphQL::TypeKinds::SCALAR
      GraphQL::Filters::InputTypes::ListScalarComparisonInputType[self]
    else
      GraphQL::Filters::InputTypes::BaseListComparisonInputType[self]
    end
  end
end

GraphQL::Schema::List.prepend monkey_patch
