require 'active_support/configurable'
require 'active_support/core_ext/module/delegation'
require 'graphql'
require_relative 'filters/version'
require_relative 'filters/utility/cached_class'

module GraphQL
  module Filters
    # This will one day be a separate gem, and in that moment we will change this reference accordingly
    CachedClass = Utility::CachedClass
    private_constant :CachedClass

    include ActiveSupport::Configurable

    config.base_input_object_class = GraphQL::Schema::InputObject

    singleton_class.delegate(*config.keys, to: :config)
  end
end

# These need to be here, after the definition of GraphQL::Filters

require_relative 'filters/input_types/complex_filter_input_type'
