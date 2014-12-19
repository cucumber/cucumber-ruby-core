module Cucumber
  module Core
    module Test
      class NameFilter
        attr_reader :name_regexps, :receiver
        private :name_regexps, :receiver

        def initialize(name_regexps, receiver)
          @name_regexps = name_regexps
          @receiver = receiver
        end

        def test_case(test_case)
          if accept?(test_case)
            test_case.describe_to(receiver)
          end
          self
        end

        def done
          @receiver.done
          self
        end

        private

        def accept?(test_case)
          name_regexps.empty? || name_regexps.any? { |name_regexp| test_case.match_name?(name_regexp) }
        end
      end
    end
  end
end
