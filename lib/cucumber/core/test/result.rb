# encoding: UTF-8¬
module Cucumber
  module Core
    module Test
      module Result
        Unknown = Struct.new(:subject) do
          def describe_to(visitor, *args)
            self
          end

          def execute(test_step, mappings, test_case_runner)
            mappings.map(test_step) # TODO: this line (and all others like it) need to move out into a Mapper
            result = test_step.execute
            test_case_runner.test_case_result = result
            result
          end
        end

        Passed = Struct.new(:subject) do
          def describe_to(visitor, *args)
            visitor.passed(*args)
            self
          end

          def execute(test_step, mappings, test_case_runner)
            mappings.map(test_step)
            result = test_step.execute
            test_case_runner.test_case_result = result if result != self
            result
          end

          def to_s
            "✓"
          end
        end

        Failed = Struct.new(:subject, :exception) do
          def describe_to(visitor, *args)
            visitor.failed(*args)
            visitor.exception(exception, *args)
            self
          end

          def execute(test_step, mappings, test_case_runner)
            mappings.map(test_step)
            test_step.skip
          end

          def to_s
            "✗"
          end
        end

        Undefined = Struct.new(:subject, :exception) do
          def describe_to(visitor, *args)
            visitor.undefined(*args)
            self
          end

          def execute(test_step, mappings, test_case_runner)
            mappings.map(test_step)
            test_step.skip
          end

          def to_s
            "✗"
          end
        end

        Skipped = Struct.new(:subject) do
          def describe_to(visitor, *args)
            visitor.skipped(*args)
            self
          end

          def to_s
            "-"
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
