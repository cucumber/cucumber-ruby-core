# encoding: UTF-8¬
module Cucumber
  module Core
    module Result
      Unknown = Struct.new(:subject) do
        def describe_to(visitor, *args)
        end
      end

      Passed = Struct.new(:subject) do
        def describe_to(visitor, *args)
          visitor.passed(*args)
        end

        def to_s
          "✓"
        end
      end

      Failed = Struct.new(:subject, :exception) do
        def describe_to(visitor, *args)
          visitor.failed(*args)
        end

        def to_s
          "✗ (#{exception.message} #{exception.backtrace})"
        end
      end
    end
  end
end
