require 'active_support/concern'

monkey_patch = Module.new do
  extend ActiveSupport::Concern

  class_methods do
    attr_accessor :filtered_type_expr, :filtered_type_null

    def filtered_type new_type=nil, null: nil
      if new_type
        raise ArgumentError, 'required argument `null:` is missing' if null.nil?

        @filtered_type_expr = new_type
        @filtered_type_null = null
      elsif filtered_type_expr
        GraphQL::Schema::Member::BuildType.parse_type filtered_type_expr, null: filtered_type_null
      elsif type_expr
        GraphQL::Schema::Member::BuildType.parse_type type_expr, null: self.null
      elsif superclass.respond_to? :filtered_type
        superclass.filtered_type
      end
    end
  end
end

GraphQL::Schema::Resolver.prepend monkey_patch
