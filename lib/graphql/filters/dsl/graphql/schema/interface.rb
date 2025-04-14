GraphQL::Schema::Interface.definition_methods do
  def comparison_input_type new_comparison_input_type=nil
    if new_comparison_input_type.present?
      @comparison_input_type = new_comparison_input_type
    else
      @comparison_input_type ||= get_comparison_input_type
    end
  end

  def get_comparison_input_type(*)
    GraphQL::Filters::InputTypes::ObjectComparisonInputType[self]
  end
end
