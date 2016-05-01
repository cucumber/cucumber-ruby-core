module Cucumber
  module Core
    module Events

      # Event Bus
      #
      # Implements an in-process pub-sub event broadcaster allowing multiple observers
      # to subscribe to different events that fire as your tests are executed.
      #
      class Bus
        class EventTypes
          attr_reader :namespaces

          def initialize(namespaces)
            @namespaces = namespaces
            @registry = build_registry
          end

          def fetch(event_id)
            @registry.fetch(event_id) do
              raise EventNameError.new(event_id, namespaces)
            end
          end

          def [](event_id)
            @registry[event_id]
          end

          private

          def build_registry
            event_types.reduce({}) { |result, type|
              id = Events::EventId(type)
              if result.key?(id)
                raise DuplicateEventTypes.new(type, result[id])
              end
              result[id] = type
              result
            }
          end

          def event_types
            event_types = @namespaces.
              map { |namespace| namespace.constants.map { |const| namespace.const_get(const) }}.flatten.
              select { |type| type.ancestors.include?(Core::Event) }
          end
        end

        def initialize(*namespaces)
          @event_types = EventTypes.new([Cucumber::Core::Events] + namespaces)
          @handlers = {}
        end

        # Register for an event. The handler proc will be called back with each of the attributes
        # of the event.
        def on(event_id, handler_object = nil, &handler_proc)
          handler = handler_proc || handler_object
          raise ArgumentError.new("Please pass either an object or a handler block") unless handler
          event_class = parse_event_id(event_id)
          handlers_for(event_class) << handler
        end

        # Broadcast an event
        def broadcast(event)
          search_namespaces(Events::EventId(event.class))
          handlers = handlers_for(event.class)
          handlers.each { |handler| handler.call(*event.attributes) }
        end

        def method_missing(event_id, *args)
          event_class = search_namespaces(Events::EventId(event_id))
          broadcast event_class.new(*args)
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
          @event_types.fetch(event_id)
        end
      end

      def self.EventId(raw)
        EventId.new(raw).to_sym
      end

      # Utility class to help translate back and forth between types and symbols for events
      class EventId
        def self.new(raw)
          case raw
          when Symbol
            super camel_case(raw)
          when Class
            super raw.name
          end
        end

        def self.camel_case(underscored_name)
          underscored_name.to_s.split("_").map { |word| word.upcase[0] + word[1..-1] }.join
        end

        def initialize(type_name)
          @type_name = type_name
        end

        def to_sym
          underscore(@type_name.split("::").last).to_sym
        end

        def underscore(string)
          string.to_s.gsub(/::/, '/').
            gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
            gsub(/([a-z\d])([A-Z])/,'\1_\2').
            tr("-", "_").
            downcase
        end
      end

      EventNameError = Class.new(StandardError) do
        def initialize(event_id, namespaces)
          super "No Event type with ID `#{event_id}` found in namespaces [#{namespaces.map(&:name).join(",")}]"
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
