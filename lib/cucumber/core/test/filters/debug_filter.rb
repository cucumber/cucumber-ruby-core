module Cucumber
  module Core
    module Test
      class DebugFilter
        def initialize(receiver)
          @receiver = receiver
        end

        def test_case(test_case, &descend)
          p [:test_case, test_case.source.last.class, test_case.location.to_s]
          descend.call(self)
          test_case.describe_to @receiver
          self
        end

        def test_step(test_step)
          p [:test_step, test_step.source.last.class, test_step.location.to_s]
          self
        end

        def done
          @receiver.done
        end
      end
    end
  end
end

