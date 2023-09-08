# frozen_string_literal: true

require 'cucumber/core/event'

describe Cucumber::Core::Event do
  describe '.new' do
    it 'generates new types of events' do
      my_event_type = described_class.new
      my_event = my_event_type.new
      expect(my_event).to be_kind_of(described_class)
    end

    it 'generates events with attributes' do
      my_event_type = described_class.new(:foo, :bar)
      my_event = my_event_type.new(1, 2)
      expect(my_event.attributes).to eq [1, 2]
      expect(my_event.foo).to eq 1
      expect(my_event.bar).to eq 2
    end
  end

  describe 'a generated event' do
    let(:my_event_type) do
      Class.new(Event.new(:foo, :bar))
    end

    it 'can be converted to a hash' do
      expect(my_event_type.new(1, 2).to_h).to eq(foo: 1, bar: 2)
    end

    it 'has an event_id' do
      expect(my_event_type.event_id).to eq(:my_event_type)
      expect(my_event_type.new(1, 2).event_id).to eq(:my_event_type)
    end
  end
end