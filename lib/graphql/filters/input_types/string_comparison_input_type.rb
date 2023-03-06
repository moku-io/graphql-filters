require_relative 'base_scalar_comparison_input_type'

module GraphQL
  module Filters
    module InputTypes
      class StringComparisonInputType < BaseScalarComparisonInputType[GraphQL::Types::String]
        argument :match,
                 String,
                 prepare: lambda { |value, _context|
                   lambda { |scope, column_name|
                     column_node = scope.table[column_name]
                     scope.where resolve_pattern(column_node, value)
                   }
                 }

        class << self
          alias inspect to_s

        private

          def resolve_pattern column_node, expression
            expression.match %r{v(?<version>\d)+/(?<full_pattern>.*)} do |match_data|
              raise 'The only supported version of pattern is v1' if match_data[:version].to_i != 1

              resolve_v1 column_node, match_data[:full_pattern]
            end
          end

          def resolve_v1 column_node, full_pattern
            full_pattern.match %r{(?<pattern>.*?)/(?<options>.*)} do |match_data|
              options = match_data[:options].chars.map(&:to_sym)

              if options.present? && options != [:i]
                raise 'The only supported option is \'i\' for case insensitive matching'
              end

              case_sensitive = !options.include?(:i)

              characters = match_data[:pattern].chars
              pattern = ''

              while characters.present?
                char = characters.shift

                pattern << case char
                           when '\\'
                             ActiveRecord::Base.sanitize_sql_like characters.shift
                           when '*'
                             '%'
                           when '.'
                             '_'
                           else
                             ActiveRecord::Base.sanitize_sql_like char
                           end
              end

              column_node.matches pattern, nil, case_sensitive
            end
          end
        end
      end
    end
  end
end
