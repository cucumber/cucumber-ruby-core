require 'cucumber/core/gherkin/writer'
require 'cucumber/core'
require 'cucumber/core/test/filters/locations_filter'

module Cucumber::Core::Test
  describe LocationsFilter do
    include Cucumber::Core::Gherkin::Writer
    include Cucumber::Core

    let(:receiver) { SpyReceiver.new }

    let(:doc) do
      gherkin do
        feature do
          scenario 'x' do
            step 'a step'
          end

          scenario 'y' do
            step 'a step'
          end
        end
      end
    end

    it "sorts by the given locations" do
      locations = [
        Cucumber::Core::Ast::Location.new('features/test.feature', 6),
        Cucumber::Core::Ast::Location.new('features/test.feature', 3)
      ]
      filter = LocationsFilter.new(locations)
      compile [doc], receiver, [filter]
      expect(receiver.test_case_locations).to eq ["features/test.feature:6", "features/test.feature:3"]
    end

    it "works with wildcard locations" do
      locations = [
        Cucumber::Core::Ast::Location.new('features/test.feature')
      ]
      filter = LocationsFilter.new(locations)
      compile [doc], receiver, [filter]
      expect(receiver.test_case_locations).to eq ["features/test.feature:3", "features/test.feature:6"]
    end

    it "filters out scenarios that don't match" do
      locations = [
        Cucumber::Core::Ast::Location.new('features/test.feature', 3)
      ]
      filter = LocationsFilter.new(locations)
      compile [doc], receiver, [filter]
      expect(receiver.test_case_locations).to eq ["features/test.feature:3"]
    end

    class SpyReceiver
      def test_case(test_case)
        test_cases << test_case
      end

      def done
      end

      def test_case_locations
        test_cases.map(&:location).map(&:to_s)
      end

      private

      def test_cases
        @test_cases ||= []
      end

    end
  end
end
