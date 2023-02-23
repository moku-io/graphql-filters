require_relative 'base_list_comparison_input_type'

module GraphQL
  module Filters
    module InputTypes
      class ListScalarComparisonInputType
        include CachedClass

        resolve_cache_miss do |value_type, klass|
          klass.new BaseListComparisonInputType[value_type] do
            argument :equals,
                     value_type,
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         scope.where(column_name => value)
                       }
                     }
            argument :not_equals,
                     value_type,
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         scope.where.not(column_name => value)
                       }
                     }
            argument :in,
                     [value_type],
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         scope.where(column_name => value)
                       }
                     }
            argument :not_in,
                     [value_type],
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         scope.where.not(column_name => value)
                       }
                     }
            argument :subset_of,
                     value_type,
                     prepare: lambda { |_value, _context|
                       lambda { |_scope, _column_name|
                         table = scope.table[column_name]
                         attribute = scope.predicate_builder.build_bind_attribute column_name, value
                         scope.where table.contained(attribute)
                       }
                     }
            argument :not_subset_of,
                     value_type,
                     prepare: lambda { |_value, _context|
                       lambda { |_scope, _column_name|
                         table = scope.table[column_name]
                         attribute = scope.predicate_builder.build_bind_attribute column_name, value
                         scope.where.not table.contained(attribute)
                       }
                     }
            argument :superset_of,
                     value_type,
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         table = scope.table[column_name]
                         attribute = scope.predicate_builder.build_bind_attribute column_name, value
                         scope.where table.contains(attribute)
                       }
                     }
            argument :not_superset_of,
                     value_type,
                     prepare: lambda { |value, _context|
                       lambda { |scope, column_name|
                         table = scope.table[column_name]
                         attribute = scope.predicate_builder.build_bind_attribute column_name, value
                         scope.where.not table.contains(attribute)
                       }
                     }
            argument :any,
                     value_type.of_type.comparison_input_type,
                     prepare: lambda { |field_comparator, _context|
                       lambda { |scope, column_name|
                         sub_scope = create_sub_scope scope, column_name, field_comparator
                         scope.where sub_scope.arel.exists
                       }
                     }
            argument :all,
                     value_type.of_type.comparison_input_type,
                     prepare: lambda { |field_comparator, _context|
                       lambda { |scope, column_name|
                         sub_scope = create_sub_scope scope, column_name, field_comparator
                         scope.where.not sub_scope.invert_where.arel.exists
                       }
                     }
            argument :none,
                     value_type.of_type.comparison_input_type,
                     prepare: lambda { |field_comparator, _context|
                       lambda { |scope, column_name|
                         sub_scope = create_sub_scope scope, column_name, field_comparator
                         scope.where.not sub_scope.arel.exists
                       }
                     }

            class << self
            private

              def create_sub_scope scope, column_name, field_comparator
                type_caster = Object.new

                type_caster.define_singleton_method :type_for_attribute do |_name|
                  scope.klass.type_for_attribute(column_name).subtype
                end

                type_caster.define_singleton_method :type_cast_for_database do |attr_name, value|
                  type = type_for_attribute attr_name
                  type.serialize value
                end

                table = Arel::Table.new 'temp_table', type_caster: type_caster
                predicate_builder = ActiveRecord::PredicateBuilder.new ActiveRecord::TableMetadata.new(
                  ActiveRecord::Base, table
                )
                temp_relation = ActiveRecord::Relation.new(ActiveRecord::Base,
                                                           table: table,
                                                           predicate_builder: predicate_builder)
                                  .from(Arel::Nodes::NamedFunction.new 'UNNEST',
                                                                       [scope.arel_table[column_name]],
                                                                       'temp_table(value)')

                field_comparator.call temp_relation, 'value'
              end
            end
          end
        end
      end
    end
  end
end
