require_relative 'base_comparison_input_type'

module GraphQL
  module Filters
    module InputTypes
      class FieldsComparisonInputType
        include CachedClass

        resolve_cache_miss do |object_type, klass|
          klass.new BaseComparisonInputType do
            graphql_name "#{object_type.graphql_name}ComparisonInput"

            define_singleton_method :own_arguments do |*args, **kwargs, &block|
              unless @loaded_fields_arguments
                object_type.fields.each_value do |field_object|
                  filter_options = field_object.filter_options

                  next unless filter_options[:enabled]

                  type = filter_options[:filtered_type]
                  comparison_input_type = filter_options[:comparison_input_type] || type.comparison_input_type

                  argument field_object.name,
                           comparison_input_type,
                           required: false,
                           prepare: lambda { |field_comparator, _context|
                             lambda { |scope|
                               if scope.klass.attribute_names.include? filter_options[:attribute_name].to_s
                                 field_comparator.call scope, filter_options[:attribute_name]
                               else
                                 field_comparator.call scope, filter_options[:association_name]
                               end
                             }
                           }
                end
                @loaded_fields_arguments = true
              end

              super(*args, **kwargs, &block)
            end

            define_method :prepare do
              lambda do |scope, association_name=nil|
                model_class = object_type.model_class

                nested_query = values.reduce model_class.all do |acc, val|
                  val.call acc
                end

                if association_name.nil?
                  unless scope.structurally_compatible? nested_query
                    raise "the produced nested query on model #{model_class}"\
                          'is not compatible with the provided scope'
                  end

                  scope.and nested_query
                else
                  scope.where association_name => nested_query
                end
              end
            end
          end
        end
      end
    end
  end
end
