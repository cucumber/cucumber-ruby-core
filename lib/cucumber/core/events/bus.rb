module Cucumber
  module Core
    module Events

      # Event Bus
      #
      # Implements an in-process pub-sub event broadcaster allowing multiple observers
      # to subscribe to events that fire as your tests are executed.
      #
      class Bus
        def initialize(registry = Events.registry)
          @event_types = registry
          @handlers = {}
        end

        # Register for an event. The handler proc will be called back with each of the attributes
        # of the event.
        def on(event_id, handler_object = nil, &handler_proc)
          handler = handler_proc || handler_object
          raise ArgumentError.new("Please pass either an object or a handler block") unless handler
          event_class = parse_event_id(event_id)
          handlers_for(event_class) << handler
        rescue EventIdError => error
          raise error, error.message + "\nDid you get the ID of the event wrong? Try one of these:\n#{@event_types.keys.join("\n")}", error.backtrace
        end

        # Broadcast an event
        def broadcast(event)
          raise ArgumentError, "Please pass an Event" unless event.is_a?(Event)
          ensure_registered(event.class)
          handlers = handlers_for(event.class)
          handlers.each { |handler| handler.call(*event.attributes) }
        end

        def method_missing(event_id, *args)
          event_class = @event_types.fetch(Events::EventId(event_id)) { super }
          broadcast event_class.new(*args)
        rescue NameError => error
          raise error, error.message + "\nDid you get the ID of the event wrong? Try one of these:\n#{@event_types.keys.join("\n")}", error.backtrace
        end

        private

        def handlers_for(event_class)
          @handlers[event_class.to_s] ||= []
        end

        def parse_event_id(raw)
          case raw
          when Class
            event_type = raw
            ensure_registered(event_type)
            event_type
          else
            search_namespaces(raw)
          end
        end

        def search_namespaces(event_id)
          @event_types.fetch(event_id) do
            raise EventIdError.new(event_id)
          end
        end

        def ensure_registered(event_type)
          return if @event_types.values.include?(event_type)
          raise EventTypeError.new(event_type)
        end
      end

      def self.EventId(raw)
        return raw if raw.is_a?(Symbol)
        EventId.new(raw.name).to_sym
      end

      # Utility class to help translate back and forth between types and symbols for events
      class EventId
        def initialize(type_name)
          @type_name = type_name
        end

        def to_sym
          underscore(@type_name.split("::").last).to_sym
        end

        private

        def underscore(string)
          string.to_s.gsub(/::/, '/').
            gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
            gsub(/([a-z\d])([A-Z])/,'\1_\2').
            tr("-", "_").
            downcase
        end
      end

      EventIdError = Class.new(StandardError) do
        def initialize(event_id)
          super "No Event type with ID `#{event_id}` is registered with the event bus."
        end
      end

      EventTypeError = Class.new(StandardError) do
        def initialize(event_type)
          super "No Event type `#{event_type}` is registered with the event bus."
        end
      end

    end
  end
end
