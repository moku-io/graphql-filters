require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
require 'ostruct'

monkey_patch = Module.new do
  extend ActiveSupport::Concern

  prepended do
    class_attribute :filter_options_defaults,
                    instance_predicate: false,
                    instance_writer: false,
                    instance_reader: true,
                    default: {
                      enabled:          true,
                      attribute_name:   :method_sym.to_proc,
                      association_name: :method_sym.to_proc
                    }
  end

  def initialize *args, filter: true, **kwargs, &block
    super(*args, **kwargs, &block)

    self.filter filter
  end

  def filter options={}, **kwargs
    # options can be either true, false, or an hash, so `if options` or `if options.present?` aren't enough

    options = case options
              when false
                {enabled: false}
              when true
                {enabled: true}
              else
                options
              end

    applied_filter_options_defaults = filter_options_defaults.transform_values do |value|
      if value.is_a? Proc
        value.call self
      else
        value
      end
    end

    kwargs.reverse_merge! applied_filter_options_defaults
    kwargs.reverse_merge! options

    filter_options.merge! kwargs
  end

  def filter_options
    @filter_options ||= {}
  end
end

GraphQL::Schema::Field.prepend monkey_patch
