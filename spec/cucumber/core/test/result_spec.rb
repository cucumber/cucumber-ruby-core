# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'cucumber/core/test/result'
require 'cucumber/core/test/duration_matcher'

module Cucumber
  module Core
    module Test
      describe Result do
        let(:visitor) { double }
        let(:args)    { double }

        describe Result::Passed do
          subject(:result) { described_class.new(duration) }
          let(:duration)   { Result::Duration.new(1 * 1000 * 1000) }

          it 'describes itself to a visitor' do
            expect(visitor).to receive(:passed).with(args)
            expect(visitor).to receive(:duration).with(duration, args)
            result.describe_to(visitor, args)
          end

          it 'converts to a string' do
            expect(result.to_s).to eq '✓'
          end

          it 'converts to a Cucumber::Message::TestResult' do
            message = result.to_message
            expect(message.status).to eq(Cucumber::Messages::TestStepResultStatus::PASSED)
          end

          it 'has a duration' do
            expect(result.duration).to eq(duration)
          end

          it 'does nothing when appending the backtrace' do
            expect(result.with_appended_backtrace(double)).to eq(result)
          end

          it 'does nothing when filtering the backtrace' do
            expect(result.with_filtered_backtrace(double)).to eq(result)
          end

          it { expect(result.to_sym).to eq(:passed) }
          it { expect(result).to be_passed }
          it { expect(result).not_to be_failed }
          it { expect(result).not_to be_undefined }
          it { expect(result).not_to be_unknown }
          it { expect(result).not_to be_skipped }
          it { expect(result).not_to be_flaky }
          it { expect(result).to be_ok }
        end

        describe Result::Failed do
          subject(:result) { described_class.new(duration, exception) }
          let(:duration)   { Result::Duration.new(1 * 1000 * 1000) }
          let(:exception)  { StandardError.new('error message') }

          it 'describes itself to a visitor' do
            expect(visitor).to receive(:failed).with(args)
            expect(visitor).to receive(:duration).with(duration, args)
            expect(visitor).to receive(:exception).with(exception, args)
            result.describe_to(visitor, args)
          end

          it 'has a duration' do
            expect(result.duration).to eq duration
          end

          it 'converts to a Cucumber::Message::TestResult' do
            message = result.to_message
            expect(message.status).to eq(Cucumber::Messages::TestStepResultStatus::FAILED)
          end

          it 'requires both constructor arguments' do
            expect { described_class.new }.to raise_error(ArgumentError)
            expect { described_class.new(duration) }.to raise_error(ArgumentError)
          end

          it 'does nothing if step has no backtrace line' do
            result.exception.set_backtrace('exception backtrace')
            step = 'does not respond_to?(:backtrace_line)'

            expect(result.with_appended_backtrace(step).exception.backtrace).to eq(['exception backtrace'])
          end

          it 'appends the backtrace line of the step' do
            result.exception.set_backtrace('exception backtrace')
            step = double
            allow(step).to receive(:backtrace_line).and_return('step_line')

            expect(result.with_appended_backtrace(step).exception.backtrace).to eq(['exception backtrace', 'step_line'])
          end

          it 'apply filters to the exception' do
            filter_class = double
            filter = double
            filtered_exception = double
            allow(filter_class).to receive(:new).with(result.exception).and_return(filter)
            allow(filter).to receive(:exception).and_return(filtered_exception)

            expect(result.with_filtered_backtrace(filter_class).exception).to equal filtered_exception
          end

          it { expect(result.to_sym).to eq(:failed) }
          it { expect(result).not_to be_passed }
          it { expect(result).to be_failed }
          it { expect(result).not_to be_undefined }
          it { expect(result).not_to be_unknown }
          it { expect(result).not_to be_skipped }
          it { expect(result).not_to be_flaky }
          it { expect(result).not_to be_ok }
        end

        describe Result::Unknown do
          subject(:result) { described_class.new }

          it "doesn't describe itself to a visitor" do
            visitor = double
            result.describe_to(visitor, args)
          end

          it 'defines a with_filtered_backtrace method' do
            expect(result.with_filtered_backtrace(double)).to eq(result)
          end

          it { expect(result.to_sym).to eq(:unknown) }
          it { expect(result).not_to be_passed }
          it { expect(result).not_to be_failed }
          it { expect(result).not_to be_undefined }
          it { expect(result).to be_unknown }
          it { expect(result).not_to be_skipped }
          it { expect(result).not_to be_flaky }

          it 'converts to a Cucumber::Message::TestResult' do
            message = result.to_message
            expect(message.status).to eq(Cucumber::Messages::TestStepResultStatus::UNKNOWN)
          end
        end

        describe Result::Raisable do
          context 'with or without backtrace' do
            subject(:result) { described_class.new }

            it 'does nothing if step has no backtrace line' do
              step = 'does not respond_to?(:backtrace_line)'

              expect(result.with_appended_backtrace(step).backtrace).to eq(nil)
            end
          end

          context 'without backtrace' do
            subject(:result) { described_class.new }

            it 'set the backtrace to the backtrace line of the step' do
              step = double
              allow(step).to receive(:backtrace_line).and_return('step_line')

              expect(result.with_appended_backtrace(step).backtrace).to eq(['step_line'])
            end

            it 'does nothing when filtering the backtrace' do
              expect(result.with_filtered_backtrace(double)).to equal result
            end
          end

          context 'with backtrace' do
            subject(:result) { described_class.new('message', 0, 'backtrace') }

            it 'appends the backtrace line of the step' do
              step = double
              allow(step).to receive(:backtrace_line).and_return('step_line')

              expect(result.with_appended_backtrace(step).backtrace).to eq(['backtrace', 'step_line'])
            end

            it 'apply filters to the backtrace' do
              filter_class = double
              filter = double
              filtered_result = double
              allow(filter_class).to receive(:new).with(result.exception).and_return(filter)
              allow(filter).to receive(:exception).and_return(filtered_result)

              expect(result.with_filtered_backtrace(filter_class)).to equal filtered_result
            end
          end
        end

        describe Result::Undefined do
          subject(:result) { described_class.new }

          it 'describes itself to a visitor' do
            expect(visitor).to receive(:undefined).with(args)
            expect(visitor).to receive(:duration).with(an_unknown_duration, args)
            result.describe_to(visitor, args)
          end

          it 'converts to a Cucumber::Message::TestResult' do
            message = result.to_message
            expect(message.status).to eq(Cucumber::Messages::TestStepResultStatus::UNDEFINED)
          end

          it { expect(result.to_sym).to eq(:undefined) }
          it { expect(result).not_to be_passed }
          it { expect(result).not_to be_failed }
          it { expect(result).to be_undefined }
          it { expect(result).not_to be_unknown }
          it { expect(result).not_to be_skipped }
          it { expect(result).not_to be_flaky }
          it { expect(result).to be_ok }

          strict = Result::StrictConfiguration.new([:undefined])
          it { expect(result).not_to be_ok(strict: strict) }
        end

        describe Result::Skipped do
          subject(:result) { described_class.new }

          it 'describes itself to a visitor' do
            expect(visitor).to receive(:skipped).with(args)
            expect(visitor).to receive(:duration).with(an_unknown_duration, args)
            result.describe_to(visitor, args)
          end

          it 'converts to a Cucumber::Message::TestResult' do
            message = result.to_message
            expect(message.status).to eq(Cucumber::Messages::TestStepResultStatus::SKIPPED)
          end

          it { expect(result.to_sym).to eq(:skipped) }
          it { expect(result).not_to be_passed }
          it { expect(result).not_to be_failed }
          it { expect(result).not_to be_undefined }
          it { expect(result).not_to be_unknown }
          it { expect(result).to be_skipped }
          it { expect(result).not_to be_flaky }
          it { expect(result).to be_ok }
        end

        describe Result::Pending do
          subject(:result) { described_class.new }

          it 'describes itself to a visitor' do
            expect(visitor).to receive(:pending).with(result, args)
            expect(visitor).to receive(:duration).with(an_unknown_duration, args)
            result.describe_to(visitor, args)
          end

          it 'converts to a Cucumber::Message::TestResult' do
            message = result.to_message
            expect(message.status).to eq(Cucumber::Messages::TestStepResultStatus::PENDING)
          end

          it { expect(result.to_sym).to eq(:pending) }
          it { expect(result).not_to be_passed }
          it { expect(result).not_to be_failed }
          it { expect(result).not_to be_undefined }
          it { expect(result).not_to be_unknown }
          it { expect(result).not_to be_skipped }
          it { expect(result).not_to be_flaky }
          it { expect(result).to be_ok }

          strict = Result::StrictConfiguration.new([:pending])
          it { expect(result).not_to be_ok(strict: strict) }
        end

        describe Result::Flaky do
          it { expect(described_class).to be_ok(strict: false) }
          it { expect(described_class).not_to be_ok(strict: true) }
        end

        describe Result::StrictConfiguration do
          subject(:strict_configuration) { described_class.new }

          describe '#set_strict' do
            context 'no type argument' do
              it 'sets all result types to the setting argument' do
                strict_configuration.set_strict(true)
                expect(strict_configuration).to be_strict(:undefined)
                expect(strict_configuration).to be_strict(:pending)
                expect(strict_configuration).to be_strict(:flaky)

                strict_configuration.set_strict(false)
                expect(strict_configuration).not_to be_strict(:undefined)
                expect(strict_configuration).not_to be_strict(:pending)
                expect(strict_configuration).not_to be_strict(:flaky)
              end
            end

            context 'with type argument' do
              it 'sets the specified result type to the setting argument' do
                strict_configuration.set_strict(true, :undefined)
                expect(strict_configuration).to be_strict(:undefined)
                expect(strict_configuration).not_to be_set(:pending)
                expect(strict_configuration).not_to be_set(:flaky)

                strict_configuration.set_strict(false, :undefined)
                expect(strict_configuration).not_to be_strict(:undefined)
                expect(strict_configuration).not_to be_set(:pending)
                expect(strict_configuration).not_to be_set(:flaky)
              end
            end
          end

          describe '#strict?' do
            context 'no type argument' do
              it 'returns true if any result type is set to strict' do
                strict_configuration.set_strict(false, :pending)
                expect(strict_configuration).not_to be_strict

                strict_configuration.set_strict(true, :flaky)
                expect(strict_configuration).to be_strict
              end
            end

            context 'with type argument' do
              it 'returns true if the specified result type is set to strict' do
                strict_configuration.set_strict(false, :pending)
                strict_configuration.set_strict(true, :flaky)

                expect(strict_configuration).not_to be_strict(:undefined)
                expect(strict_configuration).not_to be_strict(:pending)
                expect(strict_configuration).to be_strict(:flaky)
              end
            end
          end

          describe '#merge!' do
            let(:merged_configuration) { described_class.new }

            it 'sets the not default values from the argument accordingly' do
              strict_configuration.set_strict(false, :undefined)
              strict_configuration.set_strict(false, :pending)
              strict_configuration.set_strict(true, :flaky)
              merged_configuration.set_strict(true, :pending)
              merged_configuration.set_strict(false, :flaky)
              strict_configuration.merge!(merged_configuration)

              expect(strict_configuration).not_to be_strict(:undefined)
              expect(strict_configuration).to be_strict(:pending)
              expect(strict_configuration).not_to be_strict(:flaky)
            end
          end
        end

        describe Result::Summary do
          let(:summary)   { described_class.new }
          let(:failed)    { Result::Failed.new(Result::Duration.new(10), exception) }
          let(:passed)    { Result::Passed.new(Result::Duration.new(11)) }
          let(:skipped)   { Result::Skipped.new }
          let(:unknown)   { Result::Unknown.new }
          let(:pending)   { Result::Pending.new }
          let(:undefined) { Result::Undefined.new }
          let(:exception) { StandardError.new }

          it 'counts failed results' do
            failed.describe_to summary
            expect(summary.total_failed).to eq 1
            expect(summary.total(:failed)).to eq 1
            expect(summary.total).to eq 1
          end

          it 'counts passed results' do
            passed.describe_to summary
            expect(summary.total_passed).to eq 1
            expect(summary.total(:passed)).to eq 1
            expect(summary.total).to eq 1
          end

          it 'counts skipped results' do
            skipped.describe_to summary
            expect(summary.total_skipped).to eq 1
            expect(summary.total(:skipped)).to eq 1
            expect(summary.total).to eq 1
          end

          it 'counts undefined results' do
            undefined.describe_to summary
            expect(summary.total_undefined).to eq 1
            expect(summary.total(:undefined)).to eq 1
            expect(summary.total).to eq 1
          end

          it 'counts abitrary raisable results' do
            flickering = Class.new(Result::Raisable) do
              def describe_to(visitor, *args)
                visitor.flickering(*args)
              end
            end

            flickering.new.describe_to summary
            expect(summary.total_flickering).to eq 1
            expect(summary.total(:flickering)).to eq 1
            expect(summary.total).to eq 1
          end

          it 'returns zero for a status where no messges have been received' do
            expect(summary.total_passed).to eq 0
            expect(summary.total(:passed)).to eq 0
            expect(summary.total_ponies).to eq 0
            expect(summary.total(:ponies)).to eq 0
          end

          it "doesn't count unknown results" do
            unknown.describe_to summary
            expect(summary.total).to eq 0
          end

          it 'counts combinations' do
            [passed, passed, failed, skipped, undefined].each { |r| r.describe_to summary }
            expect(summary.total).to eq 5
            expect(summary.total_passed).to eq 2
            expect(summary.total_failed).to eq 1
            expect(summary.total_skipped).to eq 1
            expect(summary.total_undefined).to eq 1
          end

          it 'records durations' do
            [passed, failed].each { |r| r.describe_to summary }
            expect(summary.durations[0]).to be_duration 11
            expect(summary.durations[1]).to be_duration 10
          end

          it 'records exceptions' do
            [passed, failed].each { |r| r.describe_to summary }
            expect(summary.exceptions).to eq [exception]
          end

          context 'ok? result' do
            it 'passed result is ok' do
              passed.describe_to summary
              expect(summary.ok?).to be true
            end

            it 'skipped result is ok' do
              skipped.describe_to summary
              expect(summary.ok?).to be true
            end

            it 'failed result is not ok' do
              failed.describe_to summary
              expect(summary.ok?).to be false
            end

            it 'pending result is ok if not strict' do
              pending.describe_to summary
              expect(summary.ok?).to be true
              strict = Result::StrictConfiguration.new([:pending])
              expect(summary.ok?(strict: strict)).to be false
            end

            it 'undefined result is ok if not strict' do
              undefined.describe_to summary
              expect(summary.ok?).to be true
              strict = Result::StrictConfiguration.new([:undefined])
              expect(summary.ok?(strict: strict)).to be false
            end

            it 'flaky result is ok if not strict' do
              summary.flaky
              expect(summary.ok?).to be true
              strict = Result::StrictConfiguration.new([:flaky])
              expect(summary.ok?(strict: strict)).to be false
            end
          end
        end

        describe Result::Duration do
          subject(:duration) { described_class.new(10) }

          it '#nanoseconds can be accessed in #tap' do
            expect(duration.tap { |duration| @duration = duration.nanoseconds }).to eq duration
            expect(@duration).to eq 10
          end
        end

        describe Result::UnknownDuration do
          subject(:duration) { described_class.new }

          it '#tap does not execute the passed block' do
            expect(duration.tap { raise 'tap executed block' }).to eq duration
          end

          it 'accessing #nanoseconds outside #tap block raises exception' do
            expect { duration.nanoseconds }.to raise_error(RuntimeError)
          end
        end
      end
    end
  end
end
