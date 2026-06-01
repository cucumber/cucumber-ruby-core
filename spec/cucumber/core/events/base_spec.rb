# frozen_string_literal: true

describe Cucumber::Core::Events::Base do
  subject(:event) { my_event_type.new(1, 2) }

  let(:my_event_type) do
    Class.new(described_class) do
      def self.event_id
        :my_event_type
      end

      def initialize(foo, bar)
        @foo = foo
        @bar = bar
        super()
      end
    end
  end

  describe '.event_id' do
    it 'must be generated for subclasses' do
      expect { described_class.event_id }.to raise_error(RuntimeError).with_message('Must be implemented in subclass')
    end
  end

  describe '#to_h' do
    it 'can be converted to a hash' do
      expect(event.to_h).to eq(foo: 1, bar: 2)
    end
  end

  describe '#event_id' do
    it 'shadows the `.event_id` class method' do
      expect(event.event_id).to eq(:my_event_type)
    end
  end
end
