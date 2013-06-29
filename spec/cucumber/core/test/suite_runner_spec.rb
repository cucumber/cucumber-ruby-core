require 'cucumber/core/test/suite_runner'
require 'cucumber/core/test/suite'
require 'cucumber/core/test/case'
require 'cucumber/core/test/step'

module Cucumber::Core::Test
  describe SuiteRunner do

    let(:runner) { SuiteRunner.new(mappings, report) }
    let(:mappings) { stub }
    let(:report)   { stub.as_null_object }

    describe "running a suite" do
      it "calls the report before running the suite" do
        suite = stub
        report.should_receive(:before_test_suite).with(suite)
        runner.test_suite(suite) {}
      end

      it "calls the report after running the suite" do
        expected_suite = stub
        report.should_receive(:after_test_suite) do |suite, result|
          suite.should eq(expected_suite)
          result.should be_a(Result::Unknown)
        end
        runner.test_suite(expected_suite) {}
      end
    end

    describe "running a case" do
      it "calls the report before running the case" do
        test_case = stub
        report.should_receive(:before_test_case).with(test_case)
        runner.test_case(test_case) {}
      end

      it "calls the report after running the case" do
        expected_test_case = stub
        report.should_receive(:after_test_case) do |test_case, result|
          test_case.should eq(expected_test_case)
          result.should be_a(Result::Unknown)
        end
        runner.test_case(expected_test_case) {}
      end

      context 'with steps' do
        let(:source) { stub }
        let(:passing_ast_step) { stub }
        let(:failing_ast_step) { stub }
        let(:passing) { Step.new([passing_ast_step]) }
        let(:failing) { Step.new([failing_ast_step]) }
        let(:test_case) { Case.new(test_steps, source) }

        before do
          mappings.stub(:execute).with(passing_ast_step).and_return(mappings)
          mappings.stub(:execute).with(failing_ast_step).and_raise
        end

        context 'that all pass' do
          let(:test_steps) { [ passing, passing ]  }

          it 'reports a passing test case' do
            report.should_receive(:after_test_case) do |test_case, result|
              result.should be_a(Result::Passed)
            end

            test_case.describe_to(runner)
          end
        end

        context 'that fail' do
          let(:test_steps) { [ failing ] }

          it 'reports a failing test case' do
            report.should_receive(:after_test_case) do |test_case, result|
              result.should be_a(Result::Failed)
            end

            test_case.describe_to(runner)
          end
        end

        context 'where the first step fails' do
          let(:test_steps) { [ failing, passing ] }

          it 'fails the test case after the first step failure' do
          end

          it 'reports the first step as failed' do
            report.should_receive(:after_test_step).with(failing, anything) do |test_step, result|
              result.should be_a(Result::Failed)
            end

            test_case.describe_to(runner)
          end

          it 'reports the second step as skipped' do
            report.should_receive(:after_test_step).with(passing, anything) do |test_step, result|
              result.should be_a(Result::Skipped)
            end

            test_case.describe_to(runner)
          end

          it 'reports the test case as failed' do
            report.should_receive(:after_test_case) do |test_case, result|
              result.should be_a(Result::Failed)
            end

            test_case.describe_to(runner)
          end

          it 'does not execute the second step' do
            mappings.should_not_receive(:execute).with(passing_ast_step)

            test_case.describe_to(runner)
          end
        end

        context 'running multiple test cases' do
          context 'when the first test case fails' do
            it 'reports the results correctly for the following test case' do
              first_test_case = Case.new([failing], source)
              last_test_case  = Case.new([passing], source)

              suite = Suite.new([first_test_case, last_test_case])

              report.should_receive(:after_test_case).with(last_test_case, anything) do |test_case, result|
                result.should be_a(Result::Passed)
              end

              suite.describe_to(runner)
            end
          end
        end

      end
    end

    describe "running a step" do
      let(:ast_step) { stub }

      context "when a passing mapping exists for the step" do
        before do
          mappings.stub(:execute).with(ast_step).and_return(mappings)
        end

        it "returns a passing result" do
          expected_test_step = Step.new([ast_step])
          report.should_receive(:after_test_step) do |test_step, result|
            test_step.should eq(expected_test_step)
            result.should eq(Result::Passed.new(expected_test_step))
          end
          runner.test_step(expected_test_step)
        end
      end

      context "when a failing mapping exists for the step" do
        let(:exception) { StandardError.new('oops') }

        before do
          mappings.stub(:execute).with(ast_step).and_raise(exception)
        end

        it "returns a failing result" do
          expected_test_step = Step.new([ast_step])
          report.should_receive(:after_test_step) do |test_step, result|
            test_step.should eq(expected_test_step)
            result.should eq(Result::Failed.new(test_step, exception))
          end
          runner.test_step(expected_test_step)
        end
      end

    end

  end
end
