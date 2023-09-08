# encoding: utf-8
# frozen_string_literal: true

require 'cucumber/core/gherkin/writer'
require 'cucumber/core'
require 'cucumber/core/test/filters/locations_filter'
require 'timeout'
require 'cucumber/core/test/location'

module Cucumber
  module Core
    describe Test::LocationsFilter do
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

      it 'sorts by the given locations' do
        locations = [
          Test::Location.new('features/test.feature', 6),
          Test::Location.new('features/test.feature', 3)
        ]
        filter = described_class.new(locations)
        compile [doc], receiver, [filter]
        expect(receiver.test_case_locations).to eq locations
      end

      it 'works with wildcard locations' do
        locations = [
          Test::Location.new('features/test.feature')
        ]
        filter = described_class.new(locations)
        compile [doc], receiver, [filter]
        expect(receiver.test_case_locations).to eq [
          Test::Location.new('features/test.feature', 3),
          Test::Location.new('features/test.feature', 6)
        ]
      end

      it "filters out scenarios that don't match" do
        locations = [
          Test::Location.new('features/test.feature', 3)
        ]
        filter = described_class.new(locations)
        compile [doc], receiver, [filter]
        expect(receiver.test_case_locations).to eq locations
      end

      describe 'matching location' do
        let(:file) { 'features/path/to/the.feature' }

        let(:test_cases) do
          receiver = double.as_null_object
          result = []
          allow(receiver).to receive(:test_case) { |test_case| result << test_case }
          compile [doc], receiver
          result
        end

        context 'for a scenario' do
          let(:doc) do
            Gherkin::Document.new(file, <<-FEATURE)
            Feature:
              Background:
                Given background

              Scenario: one
                Given one a

              # comment
              @tags
              Scenario: two
                Given two a
                And two b

              Scenario: three
                Given three b

              Scenario: with docstring
                Given a docstring
                  """
                  this is a docstring
                  """

              Scenario: with a table
                Given a table
                  | a | b |
                  | 1 | 2 |
                  | 3 | 4 |

            FEATURE
          end

          def test_case_named(name)
            test_cases.find { |c| c.name == name }
          end

          it 'matches the location on a background step to all scenarios' do
            location = Test::Location.new(file, 3)
            filter = described_class.new([location])
            compile [doc], receiver, [filter]
            expect(receiver.test_case_locations).to eq test_cases.map(&:location)
          end

          it 'matches the precise location of the scenario' do
            location = test_case_named('two').location
            filter = described_class.new([location])
            compile [doc], receiver, [filter]
            expect(receiver.test_case_locations).to eq [test_case_named('two').location]
          end

          it 'matches multiple locations' do
            good_location = Test::Location.new(file, 10)
            bad_location = Test::Location.new(file, 7)
            filter = described_class.new([good_location, bad_location])
            compile [doc], receiver, [filter]
            expect(receiver.test_case_locations).to eq [test_case_named('two').location]
          end

          it 'matches a location on the first step of the scenario' do
            location = Test::Location.new(file, 11)
            filter = described_class.new([location])
            compile [doc], receiver, [filter]
            expect(receiver.test_case_locations).to eq [test_case_named('two').location]
          end

          it 'matches a location on the last step of the scenario' do
            location = Test::Location.new(file, 12)
            filter = described_class.new([location])
            compile [doc], receiver, [filter]
            expect(receiver.test_case_locations).to eq [test_case_named('two').location]
          end

          it "matches a location on the scenario's tags" do
            location = Test::Location.new(file, 9)
            filter = described_class.new([location])
            compile [doc], receiver, [filter]
            expect(receiver.test_case_locations).to eq [test_case_named('two').location]
          end

          it 'does not return a matched location on a whitespace line' do
            location = Test::Location.new(file, 13)
            filter = described_class.new([location])
            compile [doc], receiver, [filter]
            expect(receiver.test_case_locations).to eq []
          end

          context 'with a docstring' do
            let(:test_case) do
              test_cases.find { |c| c.name == 'with docstring' }
            end

            it 'matches a location at the start the docstring' do
              location = Test::Location.new(file, 17)
              filter = described_class.new([location])
              compile [doc], receiver, [filter]
              expect(receiver.test_case_locations).to eq [test_case_named('with docstring').location]
            end

            it 'matches a location in the middle of the docstring' do
              location = Test::Location.new(file, 18)
              filter = described_class.new([location])
              compile [doc], receiver, [filter]
              expect(receiver.test_case_locations).to eq [test_case_named('with docstring').location]
            end

            it 'matches a location at the end of the docstring' do
              location = Test::Location.new(file, 19)
              filter = described_class.new([location])
              compile [doc], receiver, [filter]
              expect(receiver.test_case_locations).to eq [test_case_named('with docstring').location]
            end
          end

          context 'with a table' do
            let(:test_case) { test_cases.find { |c| c.name == 'with a table' } }
            let(:starting_location) { Test::Location.new(file, 23) }
            let(:midpoint_location) { Test::Location.new(file, 24) }
            let(:ending_location) { Test::Location.new(file, 25) }

            it 'matches a location at the start of the table' do
              filter = described_class.new([starting_location])
              compile [doc], receiver, [filter]
              expect(receiver.test_case_locations).to eq [test_case_named('with a table').location]
            end

            it 'matches a location at the middle of the table' do
              filter = described_class.new([midpoint_location])
              compile [doc], receiver, [filter]
              expect(receiver.test_case_locations).to eq [test_case_named('with a table').location]
            end

            it 'matches a location at the end of the table' do
              filter = described_class.new([ending_location])
              compile [doc], receiver, [filter]
              expect(receiver.test_case_locations).to eq [test_case_named('with a table').location]
            end
          end

          context 'with duplicate locations in the filter' do
            it 'matches each test case only once' do
              location_tc_two = test_case_named('two').location
              location_tc_one = test_case_named('one').location
              location_last_step_tc_two = Test::Location.new(file, 12)
              filter = described_class.new([location_tc_two, location_tc_one, location_last_step_tc_two])
              compile [doc], receiver, [filter]
              expect(receiver.test_case_locations).to eq [test_case_named('two').location, test_case_named('one').location]
            end
          end
        end

        context 'for a scenario outline' do
          let(:doc) do
            Gherkin::Document.new(file, <<-FEATURE)
            Feature:

              Scenario: one
                Given one a

              # comment on line 6
              @tags-on-line-7
              Scenario Outline: two <arg>
                Given two a
                And two <arg>
                  """
                  docstring
                  """

                # comment on line 15
                @tags-on-line-16
                Examples: x1
                  | arg |
                  | b   |

                Examples: x2
                  | arg |
                  | c   |
                  | d   |

              Scenario: three
                Given three b
            FEATURE
          end

          let(:test_case) { test_cases.find { |c| c.name == 'two b' } }
          let(:row_location) { Test::Location.new(file, 19) }
          let(:start_of_outline_location) { Test::Location.new(file, 8) }
          let(:middle_of_outline_location) { Test::Location.new(file, 10) }
          let(:outline_tags_location) { Test::Location.new(file, 7) }

          it 'matches row location to the test case of the row' do
            filter = described_class.new([row_location])
            compile [doc], receiver, [filter]
            expect(receiver.test_case_locations).to eq [test_case.location]
          end

          it 'matches outline location with the all test cases of all the tables' do
            filter = described_class.new([start_of_outline_location])
            compile [doc], receiver, [filter]
            expect(receiver.test_case_locations.map(&:line)).to eq([19, 23, 24])
          end

          it 'matches a location on a step of the scenario outline with all test cases of all the tables' do
            filter = described_class.new([middle_of_outline_location])
            compile [doc], receiver, [filter]
            expect(receiver.test_case_locations.map(&:line)).to eq [19, 23, 24]
          end

          it "matches a location on the scenario outline's tags with all test cases of all the tables" do
            location = Test::Location.new(file, 7)
            filter = described_class.new([outline_tags_location])
            compile [doc], receiver, [filter]
            expect(receiver.test_case_locations.map(&:line)).to eq [19, 23, 24]
          end

          it "doesn't match the location of the examples line" do
            location = Test::Location.new(file, 17)
            filter = described_class.new([location])
            compile [doc], receiver, [filter]
            expect(receiver.test_case_locations).to eq []
          end
        end
      end

      context 'under load', slow: true do
        num_features = 50
        num_scenarios_per_feature = 50

        let(:docs) do
          (1..num_features).map do |i|
            gherkin("features/test_#{i}.feature") do
              feature do
                (1..num_scenarios_per_feature).each do |j|
                  scenario "scenario #{j}" do
                    step 'text'
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
              line = 3 + ((j - 1) * 3)
              Test::Location.new("features/test_#{i}.feature", line)
            end
          end.flatten
        end

        max_duration_ms = 10_000
        max_duration_ms *= 2.5 if defined?(JRUBY_VERSION)
        it "filters #{num_features * num_scenarios_per_feature} test cases within #{max_duration_ms}ms" do
          filter = described_class.new(locations)
          Timeout.timeout(max_duration_ms / 1000.0) do
            compile docs, receiver, [filter]
          end
          expect(receiver.test_cases.length).to eq num_features * num_scenarios_per_feature
        end
      end
    end

    class SpyReceiver
      def test_case(test_case)
        test_cases << test_case
      end

      def done
      end

      def test_case_locations
        test_cases.map(&:location)
      end

      def test_cases
        @test_cases ||= []
      end
    end
  end
end
