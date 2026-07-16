# frozen_string_literal: true

require 'cucumber/core/test/result'
require 'support/duration_matcher'

describe Cucumber::Core::Test::Result::Flaky do
  subject(:result) { described_class.new }

  describe '.ok?' do
    it { expect(described_class).to be_ok }
  end
end
