# frozen_string_literal: true

require 'cucumber/core/event_bus'

module Cucumber
  module Core
    module Events
      class TestEvent < Core::Event.new(:some_attribute)
      end

      AnotherTestEvent = Core::Event.new

      UnregisteredEvent = Core::Event.new
    end

    describe EventBus do
      let(:event_bus) { described_class.new(registry) }
      let(:registry) { { test_event: Events::TestEvent, another_test_event: Events::AnotherTestEvent } }

      context 'when broadcasting events' do
        it 'can broadcast by calling a method named after the event ID' do
          called = false
          event_bus.on(:test_event) { called = true }
          event_bus.test_event

          expect(called).to be true
        end

        it 'can broadcast by calling the `broadcast` method with an instance of the event type' do
          called = false
          event_bus.on(:test_event) { called = true }
          event_bus.broadcast(Events::TestEvent.new(:some_attribute))

          expect(called).to be true
        end

        it 'calls a subscriber for an event, passing details of the event' do
          received_payload = nil
          event_bus.on(:test_event) { |event| received_payload = event }
          event_bus.test_event :some_attribute

          expect(received_payload.some_attribute).to eq(:some_attribute)
        end

        it 'does not call subscribers for other events' do
          handler_called = false
          event_bus.on :test_event do
            handler_called = true
          end

          event_bus.another_test_event

          expect(handler_called).to be false
        end

        it 'broadcasts to multiple subscribers' do
          received_events = []
          event_bus.on :test_event do
            received_events << :event
          end
          event_bus.on :test_event do
            received_events << :event
          end

          event_bus.test_event(:some_attribute)

          expect(received_events.length).to eq(2)
        end

        it "raises an error when given an event to broadcast that it doesn't recognise" do
          expect { event_bus.some_unknown_event }.to raise_error(NameError)
        end

        describe '#broadcast method' do
          it 'must be passed an instance of a registered event type' do
            expect { event_bus.broadcast(Events::UnregisteredEvent) }.to raise_error(ArgumentError)
          end
        end
      end

      context 'when subscribing to events' do
        let(:regular_handler) do
          Class.new do
            attr_reader :received_payload

            def call(event)
              @received_payload = event
            end
          end
        end

        let(:proc_handler) do
          Class.new do
            attr_reader :received_payload

            def initialize(event_bus)
              event_bus.on :test_event, &method(:on_test_event)
            end

            def on_test_event(event)
              @received_payload = event
            end
          end
        end

        it 'allows subscription by symbol (Event ID)' do
          received_payload = nil
          event_bus.on(:test_event) do |event|
            received_payload = event
          end

          event_bus.test_event :some_attribute

          expect(received_payload.some_attribute).to eq(:some_attribute)
        end

        it 'raises an error if you use an unknown Event ID' do
          expect { event_bus.on(:some_unknown_event) { :whatever } }.to raise_error(ArgumentError)
        end

        it 'allows handlers that are objects with a `call` method' do
          handler = regular_handler.new
          event_bus.on(:test_event, handler)

          event_bus.test_event :some_attribute

          expect(handler.received_payload.some_attribute).to eq(:some_attribute)
        end

        it 'allows handlers that are procs' do
          handler = proc_handler.new(event_bus)

          event_bus.test_event :some_attribute
          expect(handler.received_payload.some_attribute).to eq(:some_attribute)
        end

        it 'sends events that were broadcast before you subscribed' do
          event_bus.test_event(:some_attribute)
          event_bus.another_test_event

          received_payload = nil
          event_bus.on(:test_event) do |event|
            received_payload = event
          end

          expect(received_payload.some_attribute).to eq(:some_attribute)
        end
      end

      it 'lets you inspect the registry' do
        expect(event_bus.event_types[:test_event]).to eq(Events::TestEvent)
      end

      it 'does not let you modify the registry' do
        expect { event_bus.event_types[:foo] = :bar }.to raise_error(RuntimeError)
      end
    end
  end
end
