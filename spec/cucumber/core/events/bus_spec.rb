require "cucumber/core/events"

module Cucumber
  module Core
    module Events

      class TestEvent < Event.new(:some_attribute)
      end

      class AnotherTestEvent < Event.new
      end

      describe Bus do
        let(:bus) { Bus.new }

        context "broadcasting events" do
          it "calls a subscriber for an event, passing details of the event" do
            received_payload = nil
            bus.on(TestEvent) do |some_attribute|
              received_payload = some_attribute
            end

            bus.test_event :some_attribute

            expect(received_payload).to eq(:some_attribute)
          end

          it "does not call subscribers for other events" do
            handler_called = false
            bus.on(TestEvent) do
              handler_called = true
            end

            bus.another_test_event

            expect(handler_called).to eq(false)
          end

          it "broadcasts to multiple subscribers" do
            received_events = []
            bus.on(TestEvent) do
              received_events << :event
            end
            bus.on(TestEvent) do
              received_events << :event
            end

            bus.test_event(:some_attribute)

            expect(received_events.length).to eq 2
          end

          it "raises an error when given an event to broadcast that it doesn't recognise" do
            expect { bus.some_unknown_event }.to raise_error(EventNameError, "Unknown Event type `SomeUnknownEvent`")
          end

          it "can search multiple namespaces for an event type" do
            module Foo
              SomeOtherEvent = Class.new(Event.new)
            end

            bus = Bus.new(Cucumber::Core::Events::Foo)
            expect { bus.test_event }.not_to raise_error
            expect { bus.some_other_event }.not_to raise_error
          end

          it "raises an error if there are event types with clashing names in different namespaces" do
            module Bar
              TestEvent = Class.new(Event.new)
            end

            bus = Bus.new(Cucumber::Core::Events::Bar)
            expect { bus.test_event }.to raise_error(DuplicateEventTypes)
          end

        end

        context "subscribing to events" do

          it "allows subscription by string" do
            received_payload = nil
            bus.on('Cucumber::Core::Events::TestEvent') do |some_attribute|
              received_payload = some_attribute
            end

            bus.test_event(:some_attribute)

            expect(received_payload).to eq(:some_attribute)
          end

          it "allows subscription by symbol (for events in the given namespace)" do
            received_payload = nil
            bus.on(:test_event) do |some_attribute|
              received_payload = some_attribute
            end

            bus.test_event :some_attribute

            expect(received_payload).to eq(:some_attribute)
          end

          it "allows handlers that are objects with a `call` method" do
            class MyHandler
              attr_reader :received_payload

              def call(some_attribute)
                @received_payload = some_attribute
              end
            end

            handler = MyHandler.new
            bus.on(TestEvent, handler)

            bus.test_event :some_attribute

            expect(handler.received_payload).to eq :some_attribute
          end

          it "allows handlers that are procs" do
            class MyProccyHandler
              attr_reader :received_payload

              def initialize(events)
                events.on :test_event, &method(:on_test_event)
              end

              def on_test_event(some_attribute)
                @received_payload = some_attribute
              end
            end

            handler = MyProccyHandler.new(bus)

            bus.test_event :some_attribute
            expect(handler.received_payload).to eq :some_attribute
          end
        end

      end
    end
  end
end
