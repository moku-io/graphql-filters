require 'active_support/concern'

monkey_patch = Module.new do
  extend ActiveSupport::Concern

  def comparison_input_type new_comparison_input_type=nil
    if new_comparison_input_type.present?
      @comparison_input_type = new_comparison_input_type
    else
      @comparison_input_type ||= of_type.comparison_input_type
    end
  end
end

GraphQL::Schema::NonNull.prepend monkey_patch
