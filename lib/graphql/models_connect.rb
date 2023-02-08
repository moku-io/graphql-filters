require 'active_support/configurable'
require 'active_support/core_ext/module/delegation'
require 'graphql'

module GraphQL
  module ModelsConnect
    include ActiveSupport::Configurable

    singleton_class.delegate(*config.keys, to: :config)
  end
end

# These need to be here, after the definition of GraphQL::ModelsConnect

require_relative 'models_connect/dsl'
