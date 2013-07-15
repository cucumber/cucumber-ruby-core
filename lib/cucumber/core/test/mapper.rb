require 'cucumber/initializer'
module Cucumber
  module Core
    module Test
      class Mapper
        include Cucumber.initializer(:mappings, :runner)

        def test_case(test_case, &descend)
          @steps= []
          descend.call(self)
          new_test_case = test_case.with_steps(@steps)
          new_test_case.describe_to(runner)
        end

        def test_step(test_step)
          @current_test_step = test_step
          @defined = nil
          mappings.define(test_step, self)
          undefined if @defined == nil
        end

        def define(&block)
          @defined = true
          @steps << @current_test_step.define(&block)
        end

        def undefined
          @steps << @current_test_step
        end
      end
    end
  end
end
