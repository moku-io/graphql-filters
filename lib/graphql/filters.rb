require 'active_support/configurable'
require 'active_support/core_ext/module/delegation'
require 'graphql/schema/input_object'
require_relative 'filters/version'
require_relative 'filters/utility/cached_class'

module Graphql
  class Filters
    # This will one day be a separate gem, and in that moment we will change this reference accordingly
    CachedClass = Utility::CachedClass
    private_constant :CachedClass

    include ActiveSupport::Configurable

    singleton_class.delegate_missing_to :config

    config.base_input_object_class = Graphql::Schema::InputObject
  end
end

# These need to be here, after the definition of GraphQL::Filters

require_relative 'filters/input_types/complex_filter_input_type'
