require 'cucumber/initializer'
module Cucumber
  module Core
    module Test
      class Mapper
        include Cucumber.initializer(:mappings, :runner)

        def test_case(test_case, &descend)
          @steps = []
          descend.call(self)
          new_test_case = test_case.with_steps(@steps)
          new_test_case.describe_to(runner)
        end

        def test_step(test_step)
          mapper = StepMapper.new(test_step)
          mappings.define(test_step, mapper)
          @steps << mapper.mapped_test_step
        end

        class StepMapper
          include Cucumber.initializer(:test_step)

          def initialize(*)
            super
            @mapped_test_step = nil
          end

          def define(&block)
            @mapped_test_step = test_step.define(&block)
          end

          def mapped_test_step
            @mapped_test_step || test_step
          end
        end

      end
    end
  end
end
