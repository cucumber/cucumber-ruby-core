require 'cucumber/core/test/runner'
require 'cucumber/core/test/case'
require 'cucumber/core/test/step'

module Cucumber::Core::Test
  describe Runner do

    let(:runner)   { Runner.new(report) }
    let(:report)   { double.as_null_object }

    context "with test cases" do
      let(:source) { double }
      let(:passing) { Step.new([double]).define {} }
      let(:failing) { Step.new([double]).define { raise execption } }
      let(:exception) { StandardError.new }

      context "with a single case" do
        let(:test_cases) { [test_case].extend(TestCaseCollection) }

        context "without steps" do
          let(:test_case) { Case.new([], source) }

          it "calls the report before running the case" do
            report.should_receive(:before_test_case).with(test_case)
            test_cases.describe_to(runner)
          end

          it "calls the report after running the case" do
            report.should_receive(:after_test_case) do |reported_test_case, result|
              reported_test_case.should eq(test_case)
              result.should be_a(Result::Unknown)
            end
            test_cases.describe_to(runner)
          end
        end

        context 'with steps' do
          let(:test_case) { Case.new(test_steps, source) }

          context 'that all pass' do
            let(:test_steps) { [ passing, passing ]  }

            it 'reports a passing test case' do
              report.should_receive(:after_test_case) do |test_case, result|
                result.should be_a(Result::Passed)
              end

              test_cases.describe_to(runner)
            end
          end

          context 'that fail' do
            let(:test_steps) { [ failing ] }

            it 'reports a failing test case' do
              report.should_receive(:after_test_case) do |test_case, result|
                result.should be_a(Result::Failed)
              end

              test_cases.describe_to(runner)
            end
          end

          context 'where the first step fails' do
            let(:test_steps) { [ failing, passing ] }

            it 'reports the first step as failed' do
              report.should_receive(:after_test_step).with(failing, anything) do |test_step, result|
                result.should be_a(Result::Failed)
              end

              test_cases.describe_to(runner)
            end

            it 'reports the second step as skipped' do
              report.should_receive(:after_test_step).with(passing, anything) do |test_step, result|
                result.should be_a(Result::Skipped)
              end

              test_cases.describe_to(runner)
            end

            it 'reports the test case as failed' do
              report.should_receive(:after_test_case) do |test_case, result|
                result.should be_a(Result::Failed)
              end

              test_cases.describe_to(runner)
            end

            it 'skips, rather than executing the second step' do
              passing.should_not_receive(:execute)
              passing.should_receive(:skip)
              test_cases.describe_to(runner)
            end
          end

        end
      end

      context 'with multiple test cases' do
        context 'when the first test case fails' do
          let(:first_test_case) { Case.new([failing], source) }
          let(:last_test_case)  { Case.new([passing], source) }
          let(:test_cases)      { [first_test_case, last_test_case].extend(TestCaseCollection) }

          it 'reports the results correctly for the following test case' do
            report.should_receive(:after_test_case).with(last_test_case, anything) do |reported_test_case, result|
              result.should be_a(Result::Passed)
            end

            test_cases.describe_to(runner)
          end
        end
      end
    end

  end

  module TestCaseCollection
    def describe_to(visitor, *args)
      each do |test_case|
        test_case.describe_to(visitor, *args)
      end
      self
    end
  end
end
