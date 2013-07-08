require 'cucumber/core/test/suite_runner'
require 'cucumber/core/test/suite'
require 'cucumber/core/test/case'
require 'cucumber/core/test/step'

module Cucumber::Core::Test
  describe SuiteRunner do

    let(:runner)   { SuiteRunner.new(mappings, report) }
    let(:mappings) { double }
    let(:report)   { double.as_null_object }
    let(:suite)    { Suite.new(test_cases) }

    context "an empty suite" do
      let(:test_cases) { [] }

      it "calls the report before running the suite" do
        report.should_receive(:before_test_suite).with(suite)
        suite.describe_to(runner)
      end

      it "calls the report after running the suite" do
        report.should_receive(:after_test_suite) do |reported_suite, result|
          reported_suite.should eq(suite)
          result.should be_a(Result::Unknown)
        end
        suite.describe_to(runner)
      end
    end

    context "with test cases" do
      let(:source) { double }
      let(:passing_ast_step) { double }
      let(:failing_ast_step) { double }
      let(:passing) { Step.new([passing_ast_step]) }
      let(:failing) { Step.new([failing_ast_step]) }

      before do
        mappings.stub(:execute).with(passing_ast_step).and_return(mappings)
        mappings.stub(:execute).with(failing_ast_step).and_raise
      end

      context "with a single case" do
        let(:test_cases) { [test_case] }

        context "without steps" do
          let(:test_case) { Case.new([], source) }

          it "calls the report before running the case" do
            report.should_receive(:before_test_case).with(test_case)
            suite.describe_to(runner)
          end

          it "calls the report after running the case" do
            report.should_receive(:after_test_case) do |reported_test_case, result|
              reported_test_case.should eq(test_case)
              result.should be_a(Result::Unknown)
            end
            suite.describe_to(runner)
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

              suite.describe_to(runner)
            end
          end

          context 'that fail' do
            let(:test_steps) { [ failing ] }

            it 'reports a failing test case' do
              report.should_receive(:after_test_case) do |test_case, result|
                result.should be_a(Result::Failed)
              end

              suite.describe_to(runner)
            end
          end

          context 'where the first step fails' do
            let(:test_steps) { [ failing, passing ] }

            it 'reports the first step as failed' do
              report.should_receive(:after_test_step).with(failing, anything) do |test_step, result|
                result.should be_a(Result::Failed)
              end

              suite.describe_to(runner)
            end

            it 'reports the second step as skipped' do
              report.should_receive(:after_test_step).with(passing, anything) do |test_step, result|
                result.should be_a(Result::Skipped)
              end

              suite.describe_to(runner)
            end

            it 'reports the test case as failed' do
              report.should_receive(:after_test_case) do |test_case, result|
                result.should be_a(Result::Failed)
              end

              suite.describe_to(runner)
            end

            it 'does not execute the second step' do
              mappings.should_not_receive(:execute).with(passing_ast_step)

              suite.describe_to(runner)
            end
          end

        end
      end

      context 'with multiple test cases' do
        context 'when the first test case fails' do
          let(:first_test_case) { Case.new([failing], source) }
          let(:last_test_case)  { Case.new([passing], source) }
          let(:test_cases)      { [first_test_case, last_test_case] }

          it 'reports the results correctly for the following test case' do
            report.should_receive(:after_test_case).with(last_test_case, anything) do |reported_test_case, result|
              result.should be_a(Result::Passed)
            end

            suite.describe_to(runner)
          end
        end
      end
    end

  end
end
