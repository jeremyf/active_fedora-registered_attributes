module ActiveFedora
  module RegisteredAttributes
    class Attribute

      attr_reader :context_class, :name, :datastream
      private :context_class

      # == Parameters:
      # @param context_class [ActiveFedora::Base, #human_attribute_name]
      #    A descendant of ActiveFedora::Base.
      #    Though generally speaking it may work with other ActiveModel descendants
      #
      # @param name [String, Symbol]
      #    The name of the attribute (i.e. "title", "subject", "description").
      # @param [Hash] options Configuration options
      # @option options [Symbol, #call] :default
      # @option options [Boolean] :displayable (true)
      # @option options [Boolean] :editable (true)
      #    By marking this attribute :editable
      # @option options [Hash] :form
      #    Additional options for a form builder (i.e. class, id, data-attribute)
      # @option options [Symbol, String, Nil, Hash] :datastream
      #    Where will the attribute persist; This can be nil. If nil, this would
      #    be a virtual attribute (i.e. attr_accessor name). If it is not nil,
      #    then see {#options_for_delegation}
      # @option options [Hash] :validates
      #    A hash that can be used as the args for ActiveModel::Validations::ClassMethods.validates
      # @option options [Boolean] :multiple (false)
      #    Can there be multiple values for this attribute?
      #    Used to derive an option for ActiveFedora::Base.delegate
      # @option options [Symbol, #call] :writer
      #    Before we persist the attribute, pass the value through the :writer
      # @option options [Symbol, #call] :reader
      #    After we retrieve the value from its persistence, transform the value via the :reader
      # @option options [#to_s] :label (internationalization)
      #    If we were to build a form from this, what would we use as the label
      # @option options [#to_s] :hint
      #    A supplement to the Attribute's :label
      def initialize(context_class, name, options = {})
        @context_class = context_class
        @options = options.symbolize_keys
        @options.assert_valid_keys(:default, :displayable, :editable, :form, :datastream, :validates, :multiple, :writer, :reader, :label, :hint)
        @datastream = @options.fetch(:datastream, false)
        @name = name
        @options[:multiple] = false unless @options.key?(:multiple)
        @options[:form] ||= {}
      end

      def multiple?
        options[:multiple]
      end

      def displayable?
        @options.fetch(:displayable, true)
      end

      def editable?
        @options.fetch(:editable, true)
      end

      def label
        default = options[:label] || name.to_s.humanize
        context_class.human_attribute_name(name, default: default)
      end

      def with_delegation_options
        yield(name, options_for_delegation) if datastream
      end

      def with_validation_options
        yield(name, options[:validates]) if options[:validates]
      end

      def with_accession_options
        yield(name, {}) if !datastream
      end

      def options_for_input(overrides = {})
        options[:form].tap {|hash|
          hash[:hint] ||= options[:hint] if options[:hint]
          hash[:label] ||= options[:label] if options[:label]
          if multiple?
            hash[:as] = 'multi_value'
            hash[:input_html] ||= {}
            hash[:input_html][:multiple] = 'multiple'
          end
        }.deep_merge(overrides)
      end

      def default(context)
        this_default = options[:default]
        case
        when this_default.respond_to?(:call) then context.instance_exec(&this_default)
        when this_default.duplicable? then this_default.dup
        else this_default
        end
      end

      def wrap_writer_method(context)
        with_writer_method_wrap do |method_name, block|
          context.instance_exec do
            original_method = instance_method(method_name)
            define_method(method_name) do |*args|
              original_method.bind(self).call(instance_exec(*args, &block))
            end
          end
        end
      end

      def wrap_reader_method(context)
        with_reader_method_wrapper do |method_name, block|
          context.instance_exec do
            original_method = instance_method(method_name)
            define_method(method_name) do |*args|
              instance_exec(original_method.bind(self).call(*args), &block)
            end
          end
        end
      end

      private

        def options_for_delegation
          if datastream.is_a?(Hash)
            datastream.merge(unique: !multiple?)
          else
            {
              to: datastream,
              unique: !multiple?
            }
          end
        end

        def with_writer_method_wrap
          method_name = "#{name}=".to_sym
          if writer = options[:writer]
            proc = writer.respond_to?(:call) ?
              writer :
              lambda { |value| send(writer, value) }
            yield(method_name, proc)
          elsif multiple?
            proc = lambda {|*values|
              Array(values).flatten.select {|value| value.present? }
            }
            yield(method_name, proc)
          end
        end

        def with_reader_method_wrapper
          if reader = options[:reader]
            method_name = "#{name}".to_sym
            proc = reader.respond_to?(:call) ?
              reader :
              lambda { |value| send(reader, value) }
            yield(method_name, proc)
          end
        end

        def options
          @options
        end

    end
  end
end
