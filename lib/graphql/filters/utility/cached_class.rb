require 'active_support/concern'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/class/attribute'

module GraphQL
  module Filters
    module Utility
      module CachedClass
        extend ActiveSupport::Concern

        included do
          next unless is_a? Class

          class_attribute :cache,
                          default: Hash.new { |h, k|
                            h[k] = Class.new
                          },
                          instance_accessor: false,
                          instance_predicate: false

          singleton_class.delegate :[], :[]=, to: :cache
          singleton_class.undef_method :new
        end

        class CacheClassConstructor
          attr_reader :key
          attr_reader :owner

          delegate_missing_to :owner

          def initialize key, owner
            @key = key
            @owner = owner
          end

          def new base_class, &block
            klass = Class.new base_class
            owner[key] = klass

            outer_self = self

            klass.define_singleton_method :inspect do
              "#{outer_self.owner}<#{outer_self.key}>"
            end

            klass.class_exec(&block)
            klass
          end
        end
        private_constant :CacheClassConstructor

        class_methods do
          def resolve_cache_miss &block
            cache.default_proc = proc do |h, k|
              class_constructor = CacheClassConstructor.new k, self
              result = block.call k, class_constructor

              h[k] = result unless h.key? k

              result
            end
          end
        end
      end
    end
  end
end
