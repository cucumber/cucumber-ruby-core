require 'cucumber/initializer'
module Cucumber
  module Core
    module Test
      class Mapper
        include Cucumber.initializer(:mappings, :runner)

        def test_case(test_case, &descend)
          mapper = CaseMapper.new(mappings)
          descend.call(mapper)
          test_case.with_steps(mapper.test_steps).describe_to(runner)
          self
        end

        def done
          runner.done
          self
        end

        class CaseMapper
          include Cucumber.initializer(:mappings)

          attr_reader :test_steps

          def initialize(*)
            super
            @test_steps = []
          end

          def test_step(test_step)
            mapper = StepMapper.new(test_step)
            test_step.describe_to(mappings, mapper)
            test_steps << mapper.mapped_test_step
          end

        end

        class StepMapper
          include Cucumber.initializer(:test_step)

          attr_reader :mapped_test_step

          def initialize(*)
            super
            @mapped_test_step = test_step
          end

          def map(&block)
            @mapped_test_step = test_step.with_mapping(&block)
          end
        end

      end
    end
  end
end
