require 'cucumber/initializer'

module Cucumber
  module Core
    module Test
      class SuiteRunner
        include Cucumber.initializer(:mappings, :report)

        def test_suite(test_suite, &descend)
          descend.call
        end

        def test_case(test_case, &descend)
          report.before_test_case(test_case)
          descend.call
          report.after_test_case(test_case, test_case_result)
        end

        def test_step(test_step)
          report.before_test_step(test_step)
          result = execute(test_step)
          test_step_result(result)
          report.after_test_step(test_step, result)
        end

        private

        def execute(test_step)
          mappings.execute(test_step.step)
          Result::Passed.new(test_step)
        rescue Exception => exception
          Result::Failed.new(test_step, exception)
        end

        def test_step_result(test_step_result)
          @test_case_result = test_step_result
        end

        def test_case_result
          @test_case_result ||= Result::Unknown.new
        end
      end
    end
  end
end
