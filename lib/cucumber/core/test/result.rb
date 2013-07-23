# encoding: UTF-8¬
module Cucumber
  module Core
    module Test
      module Result
        Unknown = Class.new do
          def describe_to(visitor, *args)
            self
          end

          def execute(test_step, test_case_runner)
            result = test_step.execute
            test_case_runner.test_case_result = result
            result
          end

          def passed?
            false
          end

          def undefined?
            false
          end

          def unknown?
            true
          end

          def skipped?
            false
          end
        end

        Passed = Class.new do
          def describe_to(visitor, *args)
            visitor.passed(*args)
            self
          end

          def execute(test_step, test_case_runner)
            result = test_step.execute
            test_case_runner.test_case_result = result if result != self
            result
          end

          def to_s
            "✓"
          end

          def passed?
            true
          end

          def undefined?
            false
          end

          def unknown?
            false
          end
          def skipped?
            false
          end
        end

        Failed = Struct.new(:exception) do
          def describe_to(visitor, *args)
            visitor.failed(*args)
            visitor.exception(exception, *args)
            self
          end

          def execute(test_step, test_case_runner)
            test_step.skip
          end

          def to_s
            "✗"
          end

          def passed?
            false
          end

          def undefined?
            false
          end

          def unknown?
            false
          end
          def skipped?
            false
          end
        end

        Undefined = Struct.new(:exception) do
          def describe_to(visitor, *args)
            visitor.undefined(*args)
            self
          end

          def execute(test_step, test_case_runner)
            test_step.skip
          end

          def to_s
            "✗"
          end

          def passed?
            false
          end

          def undefined?
            true
          end

          def unknown?
            false
          end
          def skipped?
            false
          end
        end

        Skipped = Class.new do
          def describe_to(visitor, *args)
            visitor.skipped(*args)
            self
          end

          def to_s
            "-"
          end

          def passed?
            false
          end

          def undefined?
            false
          end

          def unknown?
            false
          end

          def skipped?
            true
          end
        end

        class Summary
          attr_reader :total_failed, 
            :total_passed, 
            :total_skipped,
            :total_undefined,
            :exceptions

          def initialize
            @total_failed =
              @total_passed = 
              @total_skipped = 
              @total_undefined = 0
            @exceptions = []
          end

          def failed(*args)
            @total_failed += 1
          end

          def passed(*args)
            @total_passed += 1
          end

          def skipped(*args)
            @total_skipped +=1
          end

          def undefined(*args)
            @total_undefined += 1
          end

          def exception(exception)
            @exceptions << exception
          end

          def total
            total_passed + total_failed + total_skipped + total_undefined
          end
        end
      end
    end
  end
end
