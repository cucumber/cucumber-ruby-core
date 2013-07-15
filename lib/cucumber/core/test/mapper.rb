module Cucumber
  module Core
    module Test
      class Mapper
        include Cucumber.initializer(:mappings, :runner)

        def test_case(test_case, &descend)
          descend.call(self)
          runner.test_case(test_case, &descend)
        end

        def test_step(test_step)
          mappings.map(test_step)
        end
      end
    end
  end
end
