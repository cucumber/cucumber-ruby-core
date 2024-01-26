# frozen_string_literal: true

require 'cucumber/core/test/timer'
require 'cucumber/core/test/duration_matcher'

describe Cucumber::Core::Test::Timer do
  let(:random_time) { 525_702_744_080_000 }
  let(:other_random_time) { 525_702_744_080_001 }

  before do
    allow(Cucumber::Core::Test::Timer::MonotonicTime).to receive(:time_in_nanoseconds).and_return(random_time, other_random_time)
  end

  it 'returns a Result::Duration object' do
    timer = described_class.new.start

    expect(timer.duration).to be_duration(1)
  end
end
