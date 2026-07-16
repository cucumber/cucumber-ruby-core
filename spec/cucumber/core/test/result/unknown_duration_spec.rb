# frozen_string_literal: true

require 'cucumber/core/test/result'
require 'support/duration_matcher'

describe Cucumber::Core::Test::Result::UnknownDuration do
  subject(:duration) { described_class.new }

  describe '#tap' do
    it 'does not execute the passed block' do
      expect(duration.tap { raise 'tap executed block' }).to eq(duration)
    end
  end

  describe '#nanoseconds' do
    it 'accessing #nanoseconds outside a #tap block raises exception' do
      expect { duration.nanoseconds }.to raise_error(RuntimeError)
    end
  end

  describe '#to_message_duration' do
    it 'returns a Duration message' do
      expect(duration.to_message_duration).to be_a Cucumber::Messages::Duration
    end

    it 'has no time duration by default' do
      expect(duration.to_message_duration).to have_attributes(seconds: 0, nanos: 0)
    end
  end
end
