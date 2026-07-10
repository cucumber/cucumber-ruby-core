# frozen_string_literal: true

require 'cucumber/core/test/result'
require 'support/duration_matcher'

describe Cucumber::Core::Test::Result do
  let(:visitor) { double }
  let(:args)    { double }

  describe Cucumber::Core::Test::Result::Summary do
    let(:summary)   { described_class.new }
    let(:failed)    { Cucumber::Core::Test::Result::Failed.new(Cucumber::Core::Test::Result::Duration.new(10), exception) }
    let(:passed)    { Cucumber::Core::Test::Result::Passed.new(Cucumber::Core::Test::Result::Duration.new(11)) }
    let(:skipped)   { Cucumber::Core::Test:: Result::Skipped.new }
    let(:unknown)   { Cucumber::Core::Test::Result::Unknown.new }
    let(:pending)   { Cucumber::Core::Test::Result::Pending.new }
    let(:undefined) { Cucumber::Core::Test::Result::Undefined.new }
    let(:exception) { StandardError.new }

    it 'counts failed results' do
      failed.describe_to(summary)

      expect(summary.total_failed).to eq(1)
      expect(summary.total(:failed)).to eq(1)
      expect(summary.total).to eq(1)
    end

    it 'counts passed results' do
      passed.describe_to(summary)

      expect(summary.total_passed).to eq(1)
      expect(summary.total(:passed)).to eq(1)
      expect(summary.total).to eq(1)
    end

    it 'counts skipped results' do
      skipped.describe_to(summary)

      expect(summary.total_skipped).to eq(1)
      expect(summary.total(:skipped)).to eq(1)
      expect(summary.total).to eq(1)
    end

    it 'counts undefined results' do
      undefined.describe_to(summary)

      expect(summary.total_undefined).to eq(1)
      expect(summary.total(:undefined)).to eq(1)
      expect(summary.total).to eq(1)
    end

    it 'counts arbitrary raisable results' do
      flickering = Class.new(Cucumber::Core::Test::Result::Raisable) do
        def describe_to(visitor, *args)
          visitor.flickering(*args)
        end
      end

      flickering.new.describe_to(summary)

      expect(summary.total_flickering).to eq(1)
      expect(summary.total(:flickering)).to eq(1)
      expect(summary.total).to eq(1)
    end

    it 'returns zero for a status where no messages have been received' do
      expect(summary.total_passed).to eq(0)
      expect(summary.total(:passed)).to eq(0)
      expect(summary.total_ponies).to eq(0)
      expect(summary.total(:ponies)).to eq(0)
    end

    it "doesn't count unknown results" do
      unknown.describe_to(summary)

      expect(summary.total).to eq(0)
    end

    it 'counts combinations' do
      [passed, passed, failed, skipped, undefined].each { |result| result.describe_to(summary) }

      expect(summary.total).to eq(5)
      expect(summary.total_passed).to eq(2)
      expect(summary.total_failed).to eq(1)
      expect(summary.total_skipped).to eq(1)
      expect(summary.total_undefined).to eq(1)
    end

    it 'records durations' do
      [passed, failed].each { |result| result.describe_to(summary) }

      expect(summary.durations[0]).to be_duration(11)
      expect(summary.durations[1]).to be_duration(10)
    end

    it 'records exceptions' do
      [passed, failed].each { |result| result.describe_to(summary) }

      expect(summary.exceptions).to eq([exception])
    end

    describe '#ok?' do
      it 'passed result is ok' do
        passed.describe_to(summary)

        expect(summary.ok?).to be true
      end

      it 'skipped result is ok' do
        skipped.describe_to(summary)

        expect(summary.ok?).to be true
      end

      it 'failed result is not ok' do
        failed.describe_to(summary)

        expect(summary.ok?).to be false
      end

      it 'pending result is not ok' do
        pending.describe_to(summary)

        expect(summary.ok?).to be false
      end

      it 'undefined result is not ok' do
        undefined.describe_to(summary)

        expect(summary.ok?).to be false
      end

      it 'flaky result is not ok' do
        summary.flaky

        expect(summary.ok?).to be false
      end
    end
  end

  describe Cucumber::Core::Test::Result::UnknownDuration do
    subject(:duration) { described_class.new }

    it '#tap does not execute the passed block' do
      expect(duration.tap { raise 'tap executed block' }).to eq duration
    end

    it 'accessing #nanoseconds outside #tap block raises exception' do
      expect { duration.nanoseconds }.to raise_error(RuntimeError)
    end
  end
end
