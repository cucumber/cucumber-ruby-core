require 'cucumber/initializer'

module Cucumber
  module Core
    module Test
      class Runner
        include Cucumber.initializer(:report)

        def test_case(test_case, &descend)
          case_runner = CaseRunner.new(report)
          report.before_test_case(test_case)
          descend.call(case_runner)
          report.after_test_case(test_case, case_runner.test_case_result)
        end

        private

        class CaseRunner
          include Cucumber.initializer(:report)

          attr_writer :test_case_result

          def test_step(test_step)
            report.before_test_step(test_step)
            test_step_result = test_case_result.execute(test_step, self)
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
