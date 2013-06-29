# encoding: UTF-8¬
module Cucumber
  module Core
    module Test
      module Result
        Unknown = Struct.new(:subject) do
          def describe_to(visitor, *args)
            self
          end

          def execute(test_step, mappings)
            mappings.execute(test_step.step)
            Result::Passed.new(test_step)
          rescue Exception => exception
            Result::Failed.new(test_step, exception)
          end
        end

        Passed = Struct.new(:subject) do
          def describe_to(visitor, *args)
            visitor.passed(*args)
            self
          end

          def execute(test_step, mappings)
            mappings.execute(test_step.step)
            Result::Passed.new(test_step)
          rescue Exception => exception
            Result::Failed.new(test_step, exception)
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

          def execute(test_step, mappings)
            return Skipped.new(test_step)
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

      end
    end
  end
end
