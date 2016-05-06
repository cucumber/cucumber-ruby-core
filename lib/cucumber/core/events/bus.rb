module Cucumber
  module Core
    module Events

      # Event Bus
      #
      # Implements an in-process pub-sub event broadcaster allowing multiple observers
      # to subscribe to events that fire as your tests are executed.
      #
      class Bus
        attr_reader :event_types

        def initialize(registry = Events.registry)
          @event_types = registry.freeze
          @handlers = {}
        end

        # Register for an event. The handler proc will be called back with each of the attributes
        # of the event.
        def on(event_id, handler_object = nil, &handler_proc)
          handler = handler_proc || handler_object
          raise ArgumentError, "Please pass either an object or a handler block" unless handler
          raise ArgumentError, "Please use a symbol for the event_id" unless event_id.is_a?(Symbol)
          raise ArgumentError, "Event ID #{event_id} is not recognised. Try one of these:\n#{event_types.keys.join("\n")}" unless is_registered_id?(event_id)
          event_class = event_types[event_id]
          handlers_for(event_class) << handler
        end

        # Broadcast an event
        def broadcast(event)
          raise ArgumentError, "Event type #{event.class} is not registered. Try one of these:\n#{event_types.values.join("\n")}" unless is_registered_type?(event.class)
          handlers = handlers_for(event.class)
          handlers.each { |handler| handler.call(event) }
        end

        def method_missing(event_id, *args)
          event_class = event_types.fetch(event_id) { super }
          broadcast event_class.new(*args)
        rescue NameError => error
          raise error, error.message + "\nDid you get the ID of the event wrong? Try one of these:\n#{event_types.keys.join("\n")}", error.backtrace
        end

        private

        def handlers_for(event_class)
          @handlers[event_class.to_s] ||= []
        end

        def is_registered_id?(event_id)
          event_types.keys.include?(event_id)
        end

        def is_registered_type?(event_type)
          event_types.values.include?(event_type)
        end
      end

    end
  end
end
