require 'cucumber/core/filter'

module Cucumber
  module Core
    module Test
      class LocationsFilter < Filter.new(:locations)

        def test_case(test_case)
          if test_case.match_locations?(@locations)
            test_case.describe_to @receiver
          end
          self
        end

      end
    end
  end
end
