module GraphQL
  module Filters
    module Filterable
      extend ActiveSupport::Concern

      included do
        unless defined?(SearchObject::Base) && include?(SearchObject::Base)
          raise 'If you don\'t use SearchObject, you must *prepend* Filterable, not *include* it.'
        end

        option :filter, type: GraphQL::Filters::InputTypes::ComplexFilterInputType[type] do |scope, filter|
          filter.call scope
        end
      end

      prepended do
        argument :filter, GraphQL::Filters::InputTypes::ComplexFilterInputType[type], required: false

        def resolve filter: nil, **kwargs
          filter.call super(**kwargs)
        end
      end
    end
  end
end
