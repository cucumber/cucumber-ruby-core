# frozen_string_literal: true

require 'cucumber/core'
require 'cucumber/core/compiler'
require 'cucumber/core/gherkin/writer'

describe Cucumber::Core::Compiler do
  include Cucumber::Core::Gherkin::Writer
  include Cucumber::Core

  def self.stubs(*names)
    names.each do |name|
      let(name) { double(name.to_s) }
    end
  end

  let(:empty_gherkin_document) do
    gherkin do
      feature do
        scenario
      end
    end
  end
  let(:single_step_gherkin_document) do
    gherkin do
      feature do
        scenario do
          step 'passing'
        end
      end
    end
  end
  let(:double_step_gherkin_document) do
    gherkin do
      feature do
        scenario do
          step 'passing'
          step 'passing'
        end
      end
    end
  end
  let(:background_step_gherkin_document) do
    gherkin do
      feature do
        background do
          step 'passing'
        end

        scenario do
          step 'passing'
        end
      end
    end
  end

  it 'compiles a feature with a single scenario' do
    compile([single_step_gherkin_document]) do |visitor|
      expect(visitor).to receive(:test_case).once.ordered.and_yield(visitor)
      expect(visitor).to receive(:test_step).once.ordered
      expect(visitor).to receive(:done).once.ordered
    end
  end

  context 'when the event_bus is provided' do
    let(:event_bus) { double }

    before do
      allow(event_bus).to receive(:envelope)
      allow(event_bus).to receive(:gherkin_source_parsed).and_return(nil)
      allow(event_bus).to receive(:test_case_created).and_return(nil)
      allow(event_bus).to receive(:test_step_created).and_return(nil)
    end

    it 'emits a TestCaseCreated event with the created Test::Case and Pickle' do
      compile([single_step_gherkin_document], event_bus) do |visitor|
        allow(visitor).to receive(:test_case)
        allow(visitor).to receive(:test_step)
        allow(visitor).to receive(:done)
        allow(event_bus).to receive(:envelope)

        expect(event_bus).to receive(:test_case_created).once
      end
    end

    it 'emits a TestStepCreated event with the created Test::Step and PickleStep' do
      compile([double_step_gherkin_document], event_bus) do |visitor|
        allow(visitor).to receive(:test_case)
        allow(visitor).to receive(:test_step)
        allow(visitor).to receive(:done)
        allow(event_bus).to receive(:envelope)

        expect(event_bus).to receive(:test_step_created).twice
      end
    end
  end

  it 'compiles a feature with a background' do
    gherkin_documents = [
      gherkin do
        feature do
          background do
            step 'passing'
          end

          scenario do
            step 'passing'
          end
        end
      end
    ]
    compile(gherkin_documents) do |visitor|
      expect(visitor).to receive(:test_case).once.ordered.and_yield(visitor)
      expect(visitor).to receive(:test_step).twice.ordered
      expect(visitor).to receive(:done).once.ordered
    end
  end

  it 'compiles multiple features' do
    compile([background_step_gherkin_document, background_step_gherkin_document]) do |visitor|
      expect(visitor).to receive(:test_case).once.ordered
      expect(visitor).to receive(:test_step).twice.ordered
      expect(visitor).to receive(:test_case).once.ordered
      expect(visitor).to receive(:test_step).twice.ordered
      expect(visitor).to receive(:done).once
    end
  end

  context 'compiling scenario outlines' do
    it 'compiles a scenario outline to test cases' do
      gherkin_documents = [
        gherkin do
          feature do
            background do
              step 'passing'
            end

            scenario_outline do
              step 'passing <arg>'
              step 'passing'

              examples 'examples 1' do
                row 'arg'
                row '1'
                row '2'
              end

              examples 'examples 2' do
                row 'arg'
                row 'a'
              end
            end
          end
        end
      ]
      compile(gherkin_documents) do |visitor|
        expect(visitor).to receive(:test_case).exactly(3).times.and_yield(visitor)
        expect(visitor).to receive(:test_step).exactly(9).times
        expect(visitor).to receive(:done).once
      end
    end

    it 'replaces arguments correctly when generating test steps' do
      gherkin_documents = [
        gherkin do
          feature do
            scenario_outline do
              step 'passing <arg1> with <arg2>'
              step 'as well as <arg3>'

              examples do
                row 'arg1', 'arg2', 'arg3'
                row '1',    '2',    '3'
              end
            end
          end
        end
      ]

      compile(gherkin_documents) do |visitor|
        expect(visitor).to receive(:test_step) do |test_step|
          expect(test_step.text).to eq 'passing 1 with 2'
        end.once.ordered

        expect(visitor).to receive(:test_step) do |test_step|
          expect(test_step.text).to eq 'as well as 3'
        end.once.ordered

        expect(visitor).to receive(:done).once.ordered
      end
    end
  end

  context 'empty scenarios' do
    it 'does create test cases for them' do
      compile([empty_gherkin_document]) do |visitor|
        expect(visitor).to receive(:test_case).once.ordered
        expect(visitor).to receive(:done).once.ordered
      end
    end
  end

  def compile(gherkin_documents, event_bus = nil)
    visitor = double
    allow(visitor).to receive(:test_suite).and_yield(visitor)
    allow(visitor).to receive(:test_case).and_yield(visitor)

    if event_bus.nil?
      event_bus = double
      allow(event_bus).to receive_messages(
        envelope: nil,
        gherkin_source_parsed: nil,
        test_case_created: nil,
        test_step_created: nil
      )
    end

    yield visitor
    super(gherkin_documents, visitor, [], event_bus)
  end
end
