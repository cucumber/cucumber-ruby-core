module Cucumber
  module Core
    module Events

      # Event Bus
      #
      # Implements an in-process pub-sub event broadcaster allowing multiple observers
      # to subscribe to different events that fire as your tests are executed.
      #
      class Bus
        def initialize(*namespaces)
          all_namespaces = [Cucumber::Core::Events] + namespaces
          @event_types = EventTypes.registry(all_namespaces)
          @handlers = {}
        end

        # Register for an event. The handler proc will be called back with each of the attributes
        # of the event.
        def on(event_id, handler_object = nil, &handler_proc)
          handler = handler_proc || handler_object
          raise ArgumentError.new("Please pass either an object or a handler block") unless handler
          event_class = parse_event_id(event_id)
          handlers_for(event_class) << handler
        rescue EventNameError => error
          raise error, error.message + "\nDid you get the ID of the event wrong? Try one of these:\n#{@event_types.keys.join("\n")}", error.backtrace
        end

        # Broadcast an event
        def broadcast(event)
          search_namespaces(Events::EventId(event.class))
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

        def parse_event_id(event_id)
          case event_id
          when Class
            return event_id
          else
            search_namespaces(event_id)
          end
        end

        def search_namespaces(event_id)
          @event_types.fetch(event_id) do
            raise EventNameError.new(event_id)
          end
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

      module EventTypes
        module_function 

        def registry(namespaces)
          event_types(namespaces).reduce({}) { |result, type|
            id = Events::EventId(type)
            raise DuplicateEventTypes.new(type, result[id]) if result.key?(id)
            result[id] = type
            result
          }
        end

        def event_types(namespaces)
          event_types = all_types(namespaces).
            select { |type| type.ancestors.include?(Core::Event) }
        end

        def all_types(namespaces)
          namespaces.
            map { |namespace| namespace.constants.
              map { |const| namespace.const_get(const) }
            }.
            flatten
        end
      end

      EventNameError = Class.new(StandardError) do
        def initialize(event_id)
          super "No Event type with ID `#{event_id}` is registered with the event bus."
        end
      end

      DuplicateEventTypes = Class.new(StandardError) do
        def initialize(type, other_type)
          id = Events::EventId(type)
          clashes = [type, other_type]
          super "Duplicate events with ID #{id} found across namespaces:\n#{clashes.join("\n")}"
        end
      end

    end
  end
end
