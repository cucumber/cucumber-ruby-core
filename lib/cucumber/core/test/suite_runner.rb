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

          attr_writer :test_case_result

          def test_step(test_step)
            report.before_test_step(test_step)
            test_step_result = test_case_result.execute(test_step, mappings, self)
            report.after_test_step(test_step, test_step_result)
          end

          def test_case_result
            @test_case_result ||= Result::Unknown.new
          end

        end
      end
    end
  end
end
