# encoding: UTF-8¬
module Cucumber
  module Core
    module Test
      module Result
        def self.status_queries(status)
          Module.new do
            [:passed, :failed, :undefined, :unknown, :skipped].each do |possible_status|
              define_method("#{possible_status}?") do
                possible_status == status
              end
            end
          end
        end

        Unknown = Class.new do
          include Result.status_queries :unknown

          def describe_to(visitor, *args)
            self
          end

          def execute(test_step, test_case_runner)
            result = test_step.execute
            test_case_runner.test_case_result = result
            result
          end
        end

        Passed = Class.new do
          include Result.status_queries :passed

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
        end

        Failed = Struct.new(:exception) do
          include Result.status_queries :failed

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

        end

        Undefined = Struct.new(:exception) do
          include Result.status_queries :undefined

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
        end

        Skipped = Class.new do
          include Result.status_queries :skipped

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
