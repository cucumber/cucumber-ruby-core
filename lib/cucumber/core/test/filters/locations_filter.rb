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
    end
  end
end
