require 'active_support/concern'
require_relative '../../../input_types/object_comparison_input_type'

monkey_patch = Module.new do
  extend ActiveSupport::Concern

  class_methods do
  protected

    def get_comparison_input_type(*)
      GraphQL::Filters::InputTypes::ObjectComparisonInputType[self]
    end
  end
end

GraphQL::Schema::Object.prepend monkey_patch
