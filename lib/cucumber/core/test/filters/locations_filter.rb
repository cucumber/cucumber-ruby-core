require 'cucumber/core/filter'

module Cucumber
  module Core
    module Test

      # Sorts and filters scenarios based on a list of locations
      class LocationsFilter < Filter.new(:filter_locations)

        def test_case(test_case)
          test_cases << test_case
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

        def sorted_test_cases
          filter_locations.map { |filter_location|
            test_cases.select { |test_case| 
              matches?(test_case, filter_location)
            }
          }.flatten
        end

        def test_cases
          @test_cases ||= []
        end

        def matches?(test_case, filter)
          return false unless test_case.location.file == filter.file
          test_case.locations.any? { |location| filter.match?(location) }
        end

      end
    end
  end
end
