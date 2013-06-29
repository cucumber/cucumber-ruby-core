require 'cucumber/initializer'

module Cucumber
  module Core
    module Test
      class SuiteRunner
        include Cucumber.initializer(:mappings, :report)

        def test_suite(test_suite, &descend)
          report.before_test_suite(test_suite)
          descend.call
          report.after_test_suite(test_suite, test_suite_result)
        end

        def test_case(test_case, &descend)
          case_runner = CaseRunner.new(mappings, report)

          report.before_test_case(test_case)
          descend.call(case_runner)
          report.after_test_case(test_case, case_runner.test_case_result)
        end

        private

        def test_suite_result
          @test_suite_result ||= Result::Unknown.new
        end

        class CaseRunner
          include Cucumber.initializer(:mappings, :report)

          def test_step(test_step)
            report.before_test_step(test_step)
            result = test_case_result.execute(test_step, mappings)
            test_step_result(result)
            report.after_test_step(test_step, result)
          end

          def test_case_result
            @test_case_result ||= Result::Unknown.new
          end

          def test_step_result(test_step_result)
            @test_case_result = test_step_result unless already_failed?
          end

          def already_failed?
            test_case_result.is_a?(Result::Failed)
          end
        end
      end
    end
  end
end
