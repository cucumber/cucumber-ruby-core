# frozen_string_literal: true

require 'cucumber/core/gherkin/writer'
require 'cucumber/core'
require 'cucumber/core/filter'

describe Cucumber::Core::Filter do
  include Cucumber::Core::Gherkin::Writer
  include Cucumber::Core

  describe '.new' do
    let(:receiver) { double.as_null_object }

    let(:doc) do
      gherkin do
        feature do
          scenario 'x' do
            step 'a step'
          end

          scenario 'y' do
            step 'a step'
          end
        end
      end
    end

    it 'creates a filter class that can pass-through by default' do
      my_filter_class = described_class.new
      my_filter = my_filter_class.new
      expect(receiver).to receive(:test_case) { |test_case|
        expect(test_case.test_steps.length).to eq 1
        expect(test_case.test_steps.first.text).to eq 'a step'
      }.twice
      compile [doc], receiver, [my_filter]
    end

    context 'customizing by subclassing' do
      let(:basic_blanking_filter) do
        # Each filter implicitly gets a :receiver attribute
        # that you need to call with the new test case
        # once you've received yours and modified it.

        Class.new(Filter.new) do
          def test_case(test_case)
            test_case.with_steps([]).describe_to(receiver)
          end
        end
      end

      let(:named_blanking_filter) do
        # You can pass the names of attributes when building a
        # filter, allowing you to have custom attributes.

        Class.new(Filter.new(:name_pattern)) do
          def test_case(test_case)
            if test_case.name =~ name_pattern
              test_case.with_steps([]).describe_to(receiver)
            else
              test_case.describe_to(receiver) # or just call `super`
            end
            self
          end
        end
      end

      it 'can override methods from the base class' do
        expect(receiver).to receive(:test_case) { |test_case| expect(test_case.test_steps.length).to eq(0) }.twice

        run(basic_blanking_filter.new)
      end

      it 'can take arguments' do
        expect(receiver).to receive(:test_case) { |test_case| expect(test_case.test_steps.length).to eq(0) }.once.ordered
        expect(receiver).to receive(:test_case) { |test_case| expect(test_case.test_steps.length).to eq(1) }.once.ordered

        run(named_blanking_filter.new(/x/))
      end
    end

    context 'customizing by using a block' do
      let(:block_blanking_filter) do
        Class.new(described_class.new) do
          def test_case(test_case)
            test_case.with_steps([]).describe_to(receiver)
          end
        end
      end

      it 'allows methods to be overridden' do
        expect(receiver).to receive(:test_case) { |test_case| expect(test_case.test_steps.length).to eq(0) }.twice

        run(block_blanking_filter.new)
      end
    end

    def run(filter)
      compile([doc], receiver, [filter])
    end
  end
end
