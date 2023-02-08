require 'active_support/concern'

monkey_patch = Module.new do
  extend ActiveSupport::Concern

  class_methods do
    def model_class new_model_class=nil
      if new_model_class.nil?
        @model_class
      else
        @model_class = new_model_class
      end
    end
  end
end

GraphQL::Schema::Object.prepend monkey_patch
