require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
require 'ostruct'

monkey_patch = Module.new do
  extend ActiveSupport::Concern
  attr_reader :filter_options

  prepended do
    next unless is_a? Class

    class_attribute :filter_options_defaults,
                    instance_predicate: false,
                    instance_writer: false,
                    instance_reader: true,
                    default: OpenStruct.new(
                      enabled: true,
                      column_name: :method_sym.to_proc
                    )
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
                {}
              else
                options
              end

    kwargs.reverse_merge! filter_options_defaults.to_h
    kwargs.merge! options

    kwargs.transform_values! do |value|
      if value.is_a? Proc
        value.call self
      else
        value
      end
    end

    @filter_options = OpenStruct.new kwargs
  end
end

GraphQL::Schema::Field.prepend monkey_patch
