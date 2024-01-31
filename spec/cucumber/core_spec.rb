# frozen_string_literal: true

require 'report_api_spy'
require 'cucumber/core'
require 'cucumber/core/filter'
require 'cucumber/core/gherkin/writer'
require 'cucumber/core/platform'
require 'cucumber/core/report/summary'
require 'cucumber/core/test/around_hook'
require 'cucumber/core/test/filters'
require 'cucumber/core/test/filters/activate_steps_for_self_test'

describe Cucumber::Core do
  include described_class
  include Cucumber::Core::Gherkin::Writer

  describe 'compiling features to a test suite' do
    context 'with two scenarios' do
      let(:gherkin_document) do
        gherkin do
          feature do
            background do
              step 'text'
            end
            scenario do
              step 'text'
            end

            scenario do
              step 'text'
              step 'text'
            end
          end
        end
      end

      it 'compiles the scenarios into two test cases' do
        visitor = ReportAPISpy.new
        compile([gherkin_document], visitor)

        expect(visitor.messages).to eq([
          :test_case,
          :test_step,
          :test_step,
          :test_case,
          :test_step,
          :test_step,
          :test_step,
          :done
        ])
      end
    end

    context 'when compiling using a tag expression' do
      let(:gherkin_document) do
        gherkin do
          feature do
            scenario tags: '@b' do
              step 'text'
            end

            scenario_outline 'foo' do
              step '<arg>'

              examples tags: '@a' do
                row 'arg'
                row 'x'
              end

              examples 'bar', tags: '@a @b' do
                row 'arg'
                row 'y'
              end
            end
          end
        end
      end

      it 'filters out test cases based on a tag expression' do
        visitor = double.as_null_object
        expect(visitor).to receive(:test_case) { |test_case| expect(test_case.name).to eq('foo') }.once

        compile([gherkin_document], visitor, [Cucumber::Core::Test::TagFilter.new(['@a', '@b'])])
      end
    end
  end

  describe 'executing a test suite' do
    subject(:gherkin_document) do
      gherkin do
        feature 'Feature name' do
          scenario 'The one that passes' do
            step 'passing'
          end

          scenario 'The one that fails' do
            step 'passing'
            step 'failing'
            step 'passing'
            step 'undefined'
          end
        end
      end
    end

    let(:event_bus) { Cucumber::Core::EventBus.new }
    let(:observed_events) { [] }
    let(:report) { Cucumber::Core::Report::Summary.new(event_bus) }

    before do
      execute [gherkin_document], [Cucumber::Core::Test::Filters::ActivateStepsForSelfTest.new] do |event_bus|
        event_bus.on(:test_case_started) do |event|
          test_case = event.test_case
          observed_events << [:test_case_started, test_case.name]
        end
        event_bus.on(:test_case_finished) do |event|
          test_case, result = *event.attributes
          observed_events << [:test_case_finished, test_case.name, result.to_sym]
        end
        event_bus.on(:test_step_started) do |event|
          test_step = event.test_step
          observed_events << [:test_step_started, test_step.text]
        end
        event_bus.on(:test_step_finished) do |event|
          test_step, result = *event.attributes
          observed_events << [:test_step_finished, test_step.text, result.to_sym]
        end
      end
    end

    it 'fires events' do
      expect(observed_events).to eq [
        [:test_case_started, 'The one that passes'],
        [:test_step_started, 'passing'],
        [:test_step_finished, 'passing', :passed],
        [:test_case_finished, 'The one that passes', :passed],
        [:test_case_started, 'The one that fails'],
        [:test_step_started, 'passing'],
        [:test_step_finished, 'passing', :passed],
        [:test_step_started, 'failing'],
        [:test_step_finished, 'failing', :failed],
        [:test_step_started, 'passing'],
        [:test_step_finished, 'passing', :skipped],
        [:test_step_started, 'undefined'],
        [:test_step_finished, 'undefined', :undefined],
        [:test_case_finished, 'The one that fails', :failed]
      ]
    end

    context 'without hooks' do
      before do
        execute([gherkin_document], [Cucumber::Core::Test::Filters::ActivateStepsForSelfTest.new], event_bus)
      end

      it 'reports on how many total test cases there were' do
        expect(report.test_cases.total).to eq(2)
      end

      it 'reports on how many total test cases passed' do
        expect(report.test_cases.total_passed).to eq(1)
      end

      it 'reports on how many total test cases failed' do
        expect(report.test_cases.total_failed).to eq(1)
      end

      it 'reports on how many total test steps there were' do
        expect(report.test_steps.total).to eq(5)
      end

      it 'reports on how many total test steps failed' do
        expect(report.test_steps.total_failed).to eq(1)
      end

      it 'reports on how many total test steps passed' do
        expect(report.test_steps.total_passed).to eq(2)
      end

      it 'reports on how many total test steps were skipped' do
        expect(report.test_steps.total_skipped).to eq(1)
      end

      it 'reports on how many total test steps were undefined' do
        expect(report.test_steps.total_undefined).to eq(1)
      end
    end

    context 'with around hooks' do
      let(:around_hooks_filter) do
        Class.new(Cucumber::Core::Filter.new(:logger)) do
          def test_case(test_case)
            test_steps = [base_step.with_action { logger << :step }]
            test_case.with_steps(test_steps).with_around_hooks([around_hook]).describe_to(receiver)
          end

          private

          def around_hook
            Cucumber::Core::Test::AroundHook.new do |run_scenario|
              logger << :before_all
              run_scenario.call
              logger << :middle
              run_scenario.call
              logger << :after_all
            end
          end

          def base_step
            Cucumber::Core::Test::Step.new('some-random-uid', 'text', nil, nil, nil)
          end
        end
      end
      let(:gherkin_document) do
        gherkin do
          feature do
            scenario do
              step 'text'
            end
          end
        end
      end

      it 'executes the test cases in the suite' do
        logger = []
        execute [gherkin_document], [around_hooks_filter.new(logger)], event_bus

        expect(report.test_cases.total).to eq(1)
        expect(report.test_cases.total_passed).to eq(1)
        expect(report.test_cases.total_failed).to eq(0)
        expect(logger).to eq [
          :before_all,
          :step,
          :middle,
          :step,
          :after_all
        ]
      end
    end

    it 'filters test cases by tag' do
      gherkin = gherkin do
        feature do
          scenario do
            step 'text'
          end

          scenario tags: '@a @b' do
            step 'text'
          end

          scenario tags: '@a' do
            step 'text'
          end
        end
      end

      execute [gherkin], [Cucumber::Core::Test::TagFilter.new(['@a'])], event_bus

      expect(report.test_cases.total).to eq(2)
    end

    it 'filters test cases by name' do
      gherkin = gherkin do
        feature 'first feature' do
          scenario 'first scenario' do
            step 'missing'
          end

          scenario 'second' do
            step 'missing'
          end
        end
      end

      execute [gherkin], [Cucumber::Core::Test::NameFilter.new([/scenario/])], event_bus

      expect(report.test_cases.total).to eq(1)
    end
  end
end
