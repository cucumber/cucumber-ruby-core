# frozen_string_literal: true

require 'cucumber/core/test/action'
require 'cucumber/core/test/duration_matcher'

describe Cucumber::Core::Test::UndefinedAction do
  let(:location) { double }
  let(:action) { described_class.new(location) }
  let(:test_step) { double }

  describe '#location' do
    it 'returns the location passed to the constructor' do
      expect(action.location).to be location
    end
  end

  describe '#execute' do
    it 'returns an undefined result' do
      expect(action.execute).to be_undefined
    end
  end

  describe '#skip' do
    it 'returns an undefined result' do
      expect(action.skip).to be_undefined
    end
  end
end
