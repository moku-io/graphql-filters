require 'active_support/concern'

monkey_patch = Module.new do
  extend ActiveSupport::Concern

  class_methods do
    def model_class new_model_class=nil
      if new_model_class.nil?
        @model_class ||= default_model_class
      else
        @model_class = new_model_class
      end
    end

    def default_model_class
      raise 'You must set an explicit model for anonymous graphql classes' if name.nil?

      default_model_name = name.delete_suffix 'Type'

      raise "No default model found for #{name}" unless const_defined? default_model_name

      const_get default_model_name
    end
  end
end

GraphQL::Schema::Object.prepend monkey_patch
