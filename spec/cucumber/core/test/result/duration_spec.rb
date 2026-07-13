# frozen_string_literal: true

require 'cucumber/core/test/result'
require 'support/duration_matcher'

describe Cucumber::Core::Test::Result::Duration do
  subject(:duration) { described_class.new(10) }

  describe '#nanoseconds' do
    before { duration.tap { |duration| @duration = duration.nanoseconds } }

    it '#nanoseconds can be accessed in #tap' do
      expect(@duration).to eq(10)
    end
  end

  describe '#to_message_duration' do
    subject(:message_duration) { duration.to_message_duration }

    it 'returns the correct message type' do
      expect(message_duration).to be_a(Cucumber::Messages::Duration)
    end

    it 'returns a message with the correct seconds and nanos' do
      expect(message_duration).to have_attributes(seconds: 0, nanos: 10)
    end
  end

  describe '#seconds_to_duration' do
    subject(:message_duration) { duration.seconds_to_duration(1.234) }

    it 'returns a hash with the correct seconds and nanos' do
      expect(message_duration).to eq({ seconds: 1, nanos: 234_000_000 })
    end
  end
end
