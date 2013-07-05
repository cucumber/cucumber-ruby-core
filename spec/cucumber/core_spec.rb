require 'cucumber/core'
require 'cucumber/core/gherkin/writer'
require 'cucumber/core/platform'

module Cucumber
  describe Core do
    include Core
    include Core::Gherkin::Writer

    describe "compiling features to a test suite" do
      it "compiles two scenarios into two test cases" do
        suite = compile(
          gherkin do
            feature do
              background do
                step
              end
              scenario do
                step
              end
              scenario do
                step
                step
              end
            end
          end
        )
        visitor = stub
        visitor.should_receive(:test_suite).once.and_yield.ordered
        visitor.should_receive(:test_case).exactly(2).times.and_yield.ordered
        visitor.should_receive(:test_step).exactly(5).times.ordered
        suite.describe_to(visitor)
      end

    end

    describe "executing a test suite" do
      class ReportSpy
        def initialize
          @test_case_summary = Core::Test::Result::Summary.new
          @test_step_summary = Core::Test::Result::Summary.new
        end

        def test_cases
          @test_case_summary
        end

        def test_steps
          @test_step_summary
        end

        def before_test_suite(test_suite)
        end

        def after_test_suite(test_suite, report)
        end

        def before_test_case(test_case)
        end

        def after_test_case(test_case, result)
          result.describe_to(@test_case_summary)
        end

        def before_test_step(test_step)
        end

        def after_test_step(test_step, result)
          result.describe_to(@test_step_summary)
        end
      end

      class FakeMappings
        Failure = Class.new(StandardError)

        def execute(step)
          raise Failure if step.name =~ /fail/
        end
      end

      it "executes the test cases in the suite" do
        suite = compile(
          gherkin do
            feature 'Feature name' do
              scenario 'The one that passes' do
                step 'passing'
              end

              scenario 'The one that fails' do
                step 'passing'
                step 'failing'
              end
            end
          end
        )
        report = ReportSpy.new
        mappings = FakeMappings.new

        execute(suite, mappings, report)

        report.test_cases.total.should eq(2)
        report.test_cases.total_passed.should eq(1)
        report.test_cases.total_failed.should eq(1)
        report.test_steps.total.should eq(3)
        report.test_steps.total_passed.should eq(2)
        report.test_steps.total_failed.should eq(1)
      end
    end
  end
end
