# frozen_string_literal: true

module Cucumber
  module Core
    class Value
      class << self
        def define(*args, **kwargs, &block)
          Builder.new(args, kwargs, block).build
        end
      end

      Builder = Struct.new(:args, :kwargs, :block) do
        def build
          validate_definition!

          klass = ::Class.new(Value)

          klass.instance_variable_set(:@members, members)

          members[:all].each do |arg|
            klass.define_method(arg) do
              @attributes[arg]
            end
          end

          klass.class_eval(&block) if block

          klass
        end

        private

        def validate_definition!
          raise ArgumentError if args.any?(/=/)

          dup_arg = members[:all].detect { |a| members[:all].count(a) > 1 }
          raise ArgumentError, "duplicate member #{dup_arg}" if dup_arg
        end

        def members
          {
            all: args + kwargs.keys,
            required: args,
            optional: kwargs
          }
        end
      end

      def members
        self.class.instance_variable_get :@members
      end

      def initialize(**kwargs)
        validate_kwargs!(kwargs)

        @attributes = {}
        members[:required].each do |arg|
          @attributes[arg] = kwargs.fetch(arg)
        end
        members[:optional].each do |arg, default|
          @attributes[arg] = kwargs.fetch(arg, default)
        end

        freeze
      end

      def inspect
        attribute_markers = @attributes.map do |key, value|
          "#{key}=#{value}"
        end.join(', ')

        display = ['value', self.class.name, attribute_markers].compact.join(' ')

        "#<#{display}>"
      end
      alias to_s inspect

      def with(**kwargs)
        return self if kwargs.empty?

        self.class.new(**@attributes.merge(kwargs))
      end

      private

      def validate_kwargs!(kwargs)
        extras = kwargs.keys - members[:all]
        raise ArgumentError, "unknown arguments #{extras.join(', ')}" if extras.any?

        missing = members[:required] - kwargs.keys
        raise ArgumentError, "missing arguments #{missing.map(&:inspect).join(', ')}" if missing.any?
      end
    end
  end
end
