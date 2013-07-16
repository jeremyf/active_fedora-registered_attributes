require 'delegate'
require 'active_support/hash_with_indifferent_access'

module ActiveFedora
  module RegisteredAttributes
    class AttributeRegistry < DelegateClass(HashWithIndifferentAccess)
      attr_accessor :context_class
      def initialize(context_class)
        @context_class = context_class
        super(HashWithIndifferentAccess.new)
      end

      def register(attribute_name, options)
        attribute = Attribute.new(context_class, attribute_name, options)
        self[attribute.name] = attribute
        yield(attribute) if block_given?
        attribute
      end

      def editable_attributes
        @editable_attributes ||= each_with_object([]) {|(name, attribute), m|
          m << attribute if attribute.editable?
          m
        }
      end

      def displayable_attributes
        @displayable_attributes ||= each_with_object([]) {|(name, attribute),m|
          m << attribute if attribute.displayable?
          m
        }
      end

      # Calculates the attribute defaults from the attribute definitions
      #
      # @return [Hash{String => Object}] the attribute defaults
      def attribute_defaults
        collect { |name, attribute| [name, attribute.default(context_class)] }
      end

      def input_options_for(attribute_name, override_options = {})
        fetch(attribute_name).options_for_input(override_options)
      rescue KeyError
        override_options
      end

      def label_for(name)
        fetch(name).label
      rescue KeyError
        name.to_s.titleize
      end
    end

  end
end
