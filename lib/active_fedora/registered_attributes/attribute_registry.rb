require 'delegate'
require 'active_support/hash_with_indifferent_access'
require 'active_fedora/registered_attributes/attribute'


module ActiveFedora
  module RegisteredAttributes
    class AttributeRegistry < DelegateClass(HashWithIndifferentAccess)
      attr_accessor :context_class
      def initialize(context_class, initial_container = HashWithIndifferentAccess.new)
        @context_class = context_class
        super(initial_container)
      end

      def copy_to(target)
        self.class.new(target, __getobj__.dup)
      end

      def register(attribute_name, options)
        attribute = Attribute.new(context_class, attribute_name, options)
        self[attribute.name] = attribute
        yield(attribute) if block_given?
        attribute
      end

      def editable_attributes
        @editable_attributes ||= select_matching_attributes { |attribute|
          attribute.editable?
        }
      end

      def displayable_attributes
        @displayable_attributes ||= select_matching_attributes { |attribute|
          attribute.displayable?
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

      private
      def select_matching_attributes
        each_with_object([]) do |(name, attribute),m|
          m << attribute if yield(attribute)
          m
        end
      end
    end

  end
end
