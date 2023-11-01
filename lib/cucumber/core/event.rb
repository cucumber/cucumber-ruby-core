# frozen_string_literal: true

module Cucumber
  module Core
    class Event
      # Macro to generate new sub-classes of {Event} with
      # attribute readers.
      def self.new(*events)
        # Use normal constructor for subclasses of Event
        return super if ancestors.index(Event) > 0

        Class.new(Event) do
          attr_reader(*events)

          define_method(:initialize) do |*attributes|
            events.zip(attributes) do |name, value|
              instance_variable_set("@#{name}".to_sym, value)
            end
          end

          def attributes
            instance_variables.map { |var| instance_variable_get(var) }
          end

          def to_h
            events.zip(attributes).to_h
          end

          def event_id
            self.class.event_id
          end

          private

          def events
            instance_variables.map { |var| (var[1..-1]).to_sym }
          end
        end
      end

      class << self
        # @return [Symbol] the underscored name of the class to be used as the key in an event registry
        def event_id
          underscore(name.split('::').last).to_sym
        end

        private

        def underscore(string)
          string
            .to_s
            .gsub('::', '/').
            gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
            gsub(/([a-z\d])([A-Z])/, '\1_\2').
            tr('-', '_').
            downcase
        end
      end
    end
  end
end
