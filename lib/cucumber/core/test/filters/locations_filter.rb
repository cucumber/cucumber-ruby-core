require 'cucumber/core/filter'

module Cucumber
  module Core
    module Test

      # Sorts and filters scenarios based on a list of locations
      class LocationsFilter < Filter.new(:locations)

        def test_case(test_case)
          possible_locations, possible_locations_index = cached_possible_locations[test_case.location.file]
          unless possible_locations
            possible_locations_index = []
            possible_locations = []
            locations.each_with_index do |location, index|
              location.file == test_case.location.file &&
                possible_locations << location &&
                possible_locations_index << index
            end
            cached_possible_locations[test_case.location.file] = [possible_locations, possible_locations_index ]
          end
          indexes = test_case.matching_location_indexes(possible_locations)
          indexes.each do |index|
            test_cases[possible_locations_index[index]] << test_case
          end
          self
        end

        def done
          sorted_test_cases.each do |test_case|
            test_case.describe_to receiver
          end
          receiver.done
          self
        end

        private

        def cached_possible_locations
          @cached_possible_locations ||= {}
        end

        def sorted_test_cases
          test_cases.flatten
        end

        def test_cases
          @test_cases ||= locations.map {[]}
        end

      end
    end
  end
end
