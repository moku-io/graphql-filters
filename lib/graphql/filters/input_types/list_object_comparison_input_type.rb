require_relative 'base_list_comparison_input_type'

module GraphQL
  module Filters
    module InputTypes
      class ListObjectComparisonInputType
        include CachedClass

        resolve_cache_miss do |value_type, klass|
          klass.new BaseListComparisonInputType[value_type] do
            raw_type = value_type.unwrap

            argument :constant,
                     Types::Boolean,
                     prepare: lambda { |value, _context|
                       lambda { |scope, _column_name=nil|
                         if value
                           scope.all
                         else
                           scope.where false
                         end
                       }
                     }
            argument :any,
                     value_type.of_type.comparison_input_type,
                     prepare: lambda { |field_comparator, _context|
                       lambda { |scope, association_name|
                         subquery = field_comparator.call raw_type.model_class.all

                         reflection = scope.reflect_on_association association_name

                         finished_subquery = apply_reflection_to_subquery reflection, scope, subquery

                         scope.where finished_subquery.arel.exists
                       }
                     }
            argument :all,
                     value_type.of_type.comparison_input_type,
                     prepare: lambda { |field_comparator, _context|
                       lambda { |scope, association_name|
                         subquery = field_comparator.call raw_type.model_class.all

                         reflection = scope.reflect_on_association association_name

                         finished_subquery = apply_reflection_to_subquery reflection, scope, subquery.invert_where

                         scope.where.not finished_subquery.arel.exists
                       }
                     }
            argument :none,
                     value_type.of_type.comparison_input_type,
                     prepare: lambda { |field_comparator, _context|
                       lambda { |scope, association_name|
                         subquery = field_comparator.call raw_type.model_class.all

                         reflection = scope.reflect_on_association association_name

                         finished_subquery = apply_reflection_to_subquery reflection, scope, subquery

                         scope.where.not finished_subquery.arel.exists
                       }
                     }

            class << self
            private

              def apply_reflection_to_subquery reflection, scope, subquery
                unless reflection.is_a? ActiveRecord::Reflection::AbstractReflection
                  raise 'Lists of objects are only supported through associations at the moment'
                end

                scope_klass = scope.klass
                scope_table = scope.table
                scope_aliased_table = scope_table.alias "other_#{scope_table.name}"

                table_metadata = ActiveRecord::TableMetadata.new scope_klass, scope_aliased_table
                predicate_builder = ActiveRecord::PredicateBuilder.new table_metadata
                aliased_relation = ActiveRecord::Relation.new scope_klass,
                                                              table: scope_aliased_table,
                                                              predicate_builder: predicate_builder

                aliased_primary_key_node = scope_aliased_table[scope.primary_key]
                scope_primary_key_node = scope_table[scope.primary_key]

                aliased_relation
                  .joins(reflection.name)
                  .merge(subquery)
                  .where(aliased_primary_key_node.eq(scope_primary_key_node))
                  .select(:id) # Improves performance
              end
            end
          end
        end
      end
    end
  end
end
