module Cucumber
  module Core
    module Test

      class NameFilter
        include Cucumber.initializer(:name_regexps, :receiver)

        def test_case(test_case)
          if accept?(test_case)
            test_case.describe_to(receiver)
          end
          self
        end

        def accept?(test_case)
          name_regexps.empty? || name_regexps.any? { |name_regexp| test_case.match_name?(name_regexp) }
        end

      end

    end
  end
end
