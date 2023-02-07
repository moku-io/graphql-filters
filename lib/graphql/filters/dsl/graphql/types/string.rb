require 'active_support/concern'
require_relative '../../../input_types/string_comparison_input_type'

monkey_patch = Module.new do
  extend ActiveSupport::Concern

  class_methods do
  protected

    def get_comparison_input_type(*)
      GraphQL::Filters::InputTypes::StringComparisonInputType
    end
  end
end

GraphQL::Types::String.prepend monkey_patch
