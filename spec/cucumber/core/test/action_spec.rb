# frozen_string_literal: true

require 'cucumber/core/test/action'
require 'cucumber/core/test/duration_matcher'

describe Cucumber::Core::Test::Action do
  it 'raises an error if created without a block' do
    expect { described_class.new }.to raise_error(ArgumentError)
  end

  describe '#location' do
    context 'with location passed to the constructor' do
      let(:location) { double }

      it 'returns the location passed to the constructor' do
        action = described_class.new(location) { :no_op }
        expect(action.location).to be location
      end
    end

    context 'without location passed to the constructor' do
      let(:block) { proc {} }

      it 'returns the location of the block passed to the constructor' do
        action = described_class.new(&block)
        expect(action.location).to eq Cucumber::Core::Test::Location.new(*block.source_location)
      end
    end
  end

  describe '#execute' do
    it 'executes the block passed to the constructor' do
      executed = false
      action = described_class.new { executed = true }
      action.execute
      expect(executed).to be_truthy
    end

    it "returns a passed result if the block doesn't fail" do
      action = described_class.new { :no_op }
      expect(action.execute).to be_passed
    end

    it 'returns a failed result when the block raises an error' do
      exception = StandardError.new
      action = described_class.new { raise exception }
      result = action.execute
      expect(result).to be_failed
      expect(result.exception).to eq exception
    end

    it 'yields the args passed to #execute to the block' do
      args = [double, double]
      args_spy = nil
      action = described_class.new { |arg1, arg2| args_spy = [arg1, arg2] }
      action.execute(*args)
      expect(args_spy).to eq args
    end

    it 'returns a pending result if a Result::Pending error is raised' do
      exception = Cucumber::Core::Test::Result::Pending.new('TODO')
      action = described_class.new { raise exception }
      result = action.execute
      expect(result).to be_pending
      expect(result.message).to eq 'TODO'
    end

    it 'returns a skipped result if a Result::Skipped error is raised' do
      exception = Cucumber::Core::Test::Result::Skipped.new('Not working right now')
      action = described_class.new { raise exception }
      result = action.execute
      expect(result).to be_skipped
      expect(result.message).to eq 'Not working right now'
    end

    it 'returns an undefined result if a Result::Undefined error is raised' do
      exception = Cucumber::Core::Test::Result::Undefined.new('new step')
      action = described_class.new { raise exception }
      result = action.execute
      expect(result).to be_undefined
      expect(result.message).to eq 'new step'
    end

    describe '#duration' do
      before do
        allow(Cucumber::Core::Test::Timer::MonotonicTime).to receive(:time_in_nanoseconds).and_return(525_702_744_080_000, 525_702_744_080_001)
      end

      it 'records the nanoseconds duration of the execution on the result' do
        action = described_class.new { :no_op }
        duration = action.execute.duration

        expect(duration).to be_duration(1)
      end

      it 'records the duration of a failed execution' do
        action = described_class.new { raise StandardError }
        duration = action.execute.duration

        expect(duration).to be_duration(1)
      end
    end
  end

  describe '#skip' do
    it 'does not execute the block' do
      executed = false
      action = described_class.new { executed = true }
      action.skip
      expect(executed).to be_falsey
    end

    it 'returns a skipped result' do
      action = described_class.new { :no_op }
      expect(action.skip).to be_skipped
    end
  end
end

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
