require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
require_relative '../../../input_types/base_comparison_input_type'

monkey_patch = Module.new do
  extend ActiveSupport::Concern

  class_methods do
    def comparison_input_type new_comparison_input_type=nil
      if new_comparison_input_type.present?
        @comparison_input_type = new_comparison_input_type
      else
        @comparison_input_type ||= get_comparison_input_type
      end
    end

  protected

    def get_comparison_input_type
      GraphQL::Filters::InputTypes::BaseComparisonInputType
    end
  end
end

GraphQL::Schema::Member.prepend monkey_patch
