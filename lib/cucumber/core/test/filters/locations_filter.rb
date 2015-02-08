require 'cucumber/core/filter'

module Cucumber
  module Core
    module Test

      # Sorts and filters scenarios based on a list of locations
      class LocationsFilter < Filter.new(:locations)

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
          locations.map { |location| test_cases_matching(location) }.flatten
        end

        def test_cases_matching(location)
          test_cases.select do |test_case|
            test_case.match_locations?([location])
          end
        end

        def test_cases
          @test_cases ||= []
        end

      end
    end
  end
end
