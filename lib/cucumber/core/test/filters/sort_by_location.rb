require 'cucumber/core/filter'

module Cucumber
  module Core
    module Test
      class SortByLocation < Filter.new(:locations)

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
          test_cases.sort_by do |test_case|
            index_of(test_case)
          end
        end

        def test_cases
          @test_cases ||= []
        end

        def index_of(test_case)
          locations.find_index do |location|
            test_case.match_locations?([location])
          end
        end
      end
    end
  end
end
