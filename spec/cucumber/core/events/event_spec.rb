require 'cucumber/core/events/event'

module Cucumber
  module Core
    module Events
      describe Event do
        describe ".new" do
          it "generates new types of events" do
            my_event_type = Event.new
            my_event = my_event_type.new
            expect(my_event).to be_kind_of(Core::Event)
          end

          it "generates events with attributes" do
            my_event_type = Event.new(:foo, :bar)
            my_event = my_event_type.new(1,2)
            expect(my_event.attributes).to eq [1, 2]
            expect(my_event.foo).to eq 1
            expect(my_event.bar).to eq 2
          end
        end

        describe "a generated event" do
          it "can be converted to a hash" do
            my_event_type = Event.new(:foo, :bar)
            my_event = my_event_type.new(1,2)
            expect(my_event.to_h).to eq foo: 1, bar: 2
          end
        end
      end
    end
  end
end
