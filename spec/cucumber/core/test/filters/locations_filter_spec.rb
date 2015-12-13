require 'cucumber/core/gherkin/writer'
require 'cucumber/core'
require 'cucumber/core/test/filters/locations_filter'
require 'timeout'

module Cucumber::Core::Test
  describe LocationsFilter do
    include Cucumber::Core::Gherkin::Writer
    include Cucumber::Core

    let(:receiver) { SpyReceiver.new }

    let(:doc) do
      gherkin('features/test.feature') do
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

    it "matches step locations to the scenario" do
      locations = [
        Cucumber::Core::Ast::Location.new('features/test.feature', 4)
      ]
      filter = LocationsFilter.new(locations)
      compile [doc], receiver, [filter]
      expect(receiver.test_case_locations).to eq ["features/test.feature:3"]
    end

    context "with scenario outlines" do
      let(:doc) do
        gherkin('features/test.feature') do
          feature do
            scenario_outline 'x' do
              step 'a step'
              examples do
                row 'header'
                row 'data1'
                row 'data2'
              end
              examples do
                row 'header'
                row 'data3'
              end
            end
          end
        end
      end

      it "matches row location the test case of the row" do
        locations = [
                     Cucumber::Core::Ast::Location.new('features/test.feature', 8),
                    ]
        filter = LocationsFilter.new(locations)
        compile [doc], receiver, [filter]
        expect(receiver.test_case_locations).to eq ["features/test.feature:8"]
      end

      it "matches examples location the all test cases of the table" do
        locations = [
                     Cucumber::Core::Ast::Location.new('features/test.feature', 6),
                    ]
        filter = LocationsFilter.new(locations)
        compile [doc], receiver, [filter]
        expect(receiver.test_case_locations).to eq ["features/test.feature:8", "features/test.feature:9"]
      end

      it "matches outline location the all test cases of all the tables" do
        locations = [
                     Cucumber::Core::Ast::Location.new('features/test.feature', 3),
                    ]
        filter = LocationsFilter.new(locations)
        compile [doc], receiver, [filter]
        expect(receiver.test_case_locations).to eq ["features/test.feature:8", "features/test.feature:9", "features/test.feature:13"]
      end

      it "matches outline step location the all test cases of all the tables" do
        locations = [
                     Cucumber::Core::Ast::Location.new('features/test.feature', 4),
                    ]
        filter = LocationsFilter.new(locations)
        compile [doc], receiver, [filter]
        expect(receiver.test_case_locations).to eq ["features/test.feature:8", "features/test.feature:9", "features/test.feature:13"]
      end
    end

    num_features = 1
    num_scenarios_per_feature = 300
    context "under load" do
      let(:docs) do
        (1..num_features).map do |i|
          gherkin("features/test_#{i}.feature") do
            feature do
              (1..num_scenarios_per_feature).each do |j|
                scenario "scenario #{j}" do
                  step
                end
              end
            end
          end
        end
      end

      num_locations = num_features
      let(:locations) do
        (1..num_locations).map do |i|
          (1..num_scenarios_per_feature).map do |j|
            line = 3 + (j - 1) * 3
            Cucumber::Core::Ast::Location.new("features/test_#{i}.feature", line)
          end
        end.flatten
      end

      max_duration_ms = 10000
      it "filters #{num_features * num_scenarios_per_feature} test cases within #{max_duration_ms}ms" do
        filter = LocationsFilter.new(locations)
        Timeout.timeout(max_duration_ms / 1000.0) do
          compile docs, receiver, [filter]
        end
        expect(receiver.test_cases.length).to eq num_features * num_scenarios_per_feature
      end

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

      def test_cases
        @test_cases ||= []
      end

    end
  end
end
