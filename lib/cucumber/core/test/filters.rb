require 'cucumber/core/test/filters/tag_filter'
module Cucumber
  module Core
    module Test

      class LocationsFilter
        def initialize(locations, receiver)
          @receiver = receiver
          @locations = locations
        end

        def test_case(test_case)
          if test_case.match_locations?(@locations)
            test_case.describe_to @receiver
          end
          self
        end

        def done
          @receiver.done
          self
        end
      end

      class NameFilter
        include Cucumber.initializer(:name_regexps, :receiver)

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
