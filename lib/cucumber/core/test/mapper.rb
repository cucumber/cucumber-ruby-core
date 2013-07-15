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
            mappings.define(test_step, mapper)
            test_steps << mapper.mapped_test_step
          end

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
