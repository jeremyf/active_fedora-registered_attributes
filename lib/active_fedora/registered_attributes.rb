require "active_fedora/registered_attributes/version"
require 'active_attr'
require "active_fedora/registered_attributes/attribute"
require "active_fedora/registered_attributes/attribute_registry"

module ActiveFedora
  module RegisteredAttributes
    extend ActiveSupport::Concern
    included do
      class_attribute :attribute_registry, instance_writer: false, instance_reader: false
    end

    delegate :attribute_defaults, to: :attribute_registry
    delegate :input_options_for, to: :attribute_registry
    delegate :label_for, to: :attribute_registry
    delegate :editable_attributes, to: :attribute_registry
    delegate :displayable_attributes, to: :attribute_registry

    def attribute_registry
      self.class.attribute_registry
    end
    private :attribute_registry

    module ClassMethods
      def attribute(attribute_name, options ={})
        self.attribute_registry ||= AttributeRegistry.new(self)
        self.attribute_registry.register(attribute_name, options) do |attribute|

          attribute.with_validation_options do |name, opts|
            validates(name, opts)
          end

          attribute.with_accession_options do |name, opts|
            attr_accessor name
          end

          attribute.with_delegation_options do |name, opts|
            delegate(name, opts)
          end

          attribute.wrap_writer_method(self)
          attribute.wrap_reader_method(self)
        end
      end
    end

    # Applies attribute default values
    def initialize(*)
      super
      apply_defaults
    end

    def terms_for_editing
      editable_attributes.collect(&:name)
    end

    def terms_for_display
      displayable_attributes.collect(&:name)
    end

    protected
    def apply_defaults(defaults=attribute_defaults)
      defaults.each do |name, value|
        if !value.nil? && !persisted?
          send("#{name}=", value) # unless send("#{name}").present?
        end
      end
    end
  end

end
