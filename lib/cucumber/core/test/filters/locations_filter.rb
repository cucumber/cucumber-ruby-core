module Cucumber
  module Core
    module Test
      class LocationsFilter
        attr_reader :locations, :receiver
        private :locations, :receiver

        def initialize(locations, receiver)
          @locations = locations
          @receiver = receiver
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
