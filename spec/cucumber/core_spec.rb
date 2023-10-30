# frozen_string_literal: true

require 'cucumber/core'
require 'cucumber/core/filter'
require 'cucumber/core/gherkin/writer'
require 'cucumber/core/report/summary'
require 'cucumber/core/test/filters/activate_steps_for_self_test'

describe Cucumber::Core do
  include described_class
  include Cucumber::Core::Gherkin::Writer

  describe 'executing a test suite' do
    let(:event_bus) { Cucumber::Core::EventBus.new }
    let(:report) { Cucumber::Core::Report::Summary.new(event_bus) }

    it 'fires events' do
      gherkin = gherkin do
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

      observed_events = []
      execute [gherkin], [Cucumber::Core::Test::Filters::ActivateStepsForSelfTest.new] do |event_bus|
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
  end
end
