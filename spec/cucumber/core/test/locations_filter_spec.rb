# frozen_string_literal: true

require 'cucumber/core/gherkin/writer'
require 'cucumber/core'
require 'cucumber/core/test/filters/locations_filter'
require 'timeout'
require 'cucumber/core/test/location'

describe Cucumber::Core::Test::LocationsFilter do
  include Cucumber::Core::Gherkin::Writer
  include Cucumber::Core

  let(:spy_receiver) do
    Class.new do
      def test_case(test_case)
        test_cases << test_case
      end

      def done; end

      def test_case_locations
        test_cases.map(&:location)
      end

      def test_cases
        @test_cases ||= []
      end
    end
  end
  let(:receiver) { spy_receiver.new }
  let(:doc) do
    gherkin('features/test.feature') do
      feature do
        scenario 'x' do
          step 'step for scenario x'
        end

        scenario 'y' do
          step 'step for scenario y'
        end
      end
    end
  end

  it 'sorts by the given locations' do
    locations = [
      Cucumber::Core::Test::Location.new('features/test.feature', 6),
      Cucumber::Core::Test::Location.new('features/test.feature', 3)
    ]
    filter = described_class.new(locations)
    compile([doc], receiver, [filter])
    expect(receiver.test_case_locations).to eq(locations)
  end

  it 'works with wildcard locations' do
    locations = [Cucumber::Core::Test::Location.new('features/test.feature')]
    filter = described_class.new(locations)
    compile([doc], receiver, [filter])
    expect(receiver.test_case_locations).to eq(
      [
        Cucumber::Core::Test::Location.new('features/test.feature', 3),
        Cucumber::Core::Test::Location.new('features/test.feature', 6)
      ]
    )
  end

  it "filters out scenarios that don't match" do
    locations = [Cucumber::Core::Test::Location.new('features/test.feature', 3)]
    filter = described_class.new(locations)
    compile([doc], receiver, [filter])
    expect(receiver.test_case_locations).to eq(locations)
  end

  describe 'matching location' do
    let(:file) { 'features/path/to/the.feature' }
    let(:test_cases) do
      receiver = double.as_null_object
      result = []
      allow(receiver).to receive(:test_case) { |test_case| result << test_case }
      compile([doc], receiver)
      result
    end

    context 'with a scenario' do
      let(:doc) do
        Cucumber::Core::Gherkin::Document.new(file, <<-FEATURE)
        Feature:
          Background:
            Given background

          Scenario: one
            Given one a

          # comment
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

          Rule: A rule with a background
            Background: A background rule
              Given background

            Scenario: with a rule and background
              Given a rule with a background

            Scenario: another with a rule and background
              Given a rule with a background

          Rule: A rule without a background
            Scenario: with a rule and no background
              Given a rule without a background

            Scenario: another with a rule and no background
              Given a rule without a background
        FEATURE
      end

      def test_case_named(name)
        test_cases.detect { |tc| tc.name == name }
      end

      it 'matches the feature location to all scenarios' do
        location = Cucumber::Core::Test::Location.new(file, 1)
        filter = described_class.new([location])
        compile([doc], receiver, [filter])
        expect(receiver.test_case_locations).to eq(test_cases.map(&:location))
      end

      it 'matches the feature background location to all scenarios' do
        location = Cucumber::Core::Test::Location.new(file, 2)
        filter = described_class.new([location])
        compile([doc], receiver, [filter])
        expect(receiver.test_case_locations).to eq(test_cases.map(&:location))
      end

      it 'matches a feature background step location to all scenarios' do
        location = Cucumber::Core::Test::Location.new(file, 3)
        filter = described_class.new([location])
        compile([doc], receiver, [filter])
        expect(receiver.test_case_locations).to eq(test_cases.map(&:location))
      end

      it "matches a rule location (containing a background) to all of the rule's scenarios" do
        location = Cucumber::Core::Test::Location.new(file, 29)
        filter = described_class.new([location])
        compile([doc], receiver, [filter])
        expect(receiver.test_case_locations).to eq(
          [
            test_case_named('with a rule and background').location,
            test_case_named('another with a rule and background').location
          ]
        )
      end

      it "matches the rule background location to all of the rule's scenarios" do
        location = Cucumber::Core::Test::Location.new(file, 30)
        filter = described_class.new([location])
        compile [doc], receiver, [filter]
        expect(receiver.test_case_locations).to eq(
          [
            test_case_named('with a rule and background').location,
            test_case_named('another with a rule and background').location
          ]
        )
      end

      it "matches a rule background step location to all of the rule's scenarios" do
        location = Cucumber::Core::Test::Location.new(file, 31)
        filter = described_class.new([location])
        compile [doc], receiver, [filter]
        expect(receiver.test_case_locations).to eq(
          [
            test_case_named('with a rule and background').location,
            test_case_named('another with a rule and background').location
          ]
        )
      end

      it "matches a rule location (without a background) to all of the rule's scenarios" do
        location = Cucumber::Core::Test::Location.new(file, 39)
        filter = described_class.new([location])
        compile [doc], receiver, [filter]
        expect(receiver.test_case_locations).to eq(
          [
            test_case_named('with a rule and no background').location,
            test_case_named('another with a rule and no background').location
          ]
        )
      end

      it 'matches a scenario location to the scenario' do
        location = test_case_named('two').location
        filter = described_class.new([location])
        compile([doc], receiver, [filter])
        expect(receiver.test_case_locations).to eq([test_case_named('two').location])
      end

      it 'matches multiple locations, ignoring whitespace locations' do
        scenario_location = Cucumber::Core::Test::Location.new(file, 5)
        another_scenario_location = Cucumber::Core::Test::Location.new(file, 10)
        whitespace_location = Cucumber::Core::Test::Location.new(file, 7)
        filter = described_class.new([scenario_location, another_scenario_location, whitespace_location])
        compile([doc], receiver, [filter])
        expect(receiver.test_case_locations).to eq(
          [
            test_case_named('one').location,
            test_case_named('two').location
          ]
        )
      end

      it 'matches the first scenario step location to the scenario' do
        location = Cucumber::Core::Test::Location.new(file, 11)
        filter = described_class.new([location])
        compile([doc], receiver, [filter])
        expect(receiver.test_case_locations).to eq([test_case_named('two').location])
      end

      it 'matches the last scenario step location to the scenario' do
        location = Cucumber::Core::Test::Location.new(file, 12)
        filter = described_class.new([location])
        compile([doc], receiver, [filter])
        expect(receiver.test_case_locations).to eq([test_case_named('two').location])
      end

      it "matches a scenario's tag location to the scenario" do
        location = Cucumber::Core::Test::Location.new(file, 9)
        filter = described_class.new([location])
        compile([doc], receiver, [filter])
        expect(receiver.test_case_locations).to eq([test_case_named('two').location])
      end

      it 'does not match a whitespace location to any scenarios' do
        location = Cucumber::Core::Test::Location.new(file, 13)
        filter = described_class.new([location])
        compile([doc], receiver, [filter])
        expect(receiver.test_case_locations).to eq([])
      end

      context 'with a docstring' do
        it 'matches a location at the start the docstring' do
          location = Cucumber::Core::Test::Location.new(file, 17)
          filter = described_class.new([location])
          compile([doc], receiver, [filter])

          expect(receiver.test_case_locations).to eq([test_case_named('with docstring').location])
        end

        it 'matches a location in the middle of the docstring' do
          location = Cucumber::Core::Test::Location.new(file, 18)
          filter = described_class.new([location])
          compile([doc], receiver, [filter])

          expect(receiver.test_case_locations).to eq([test_case_named('with docstring').location])
        end

        it 'matches a location at the end of the docstring' do
          location = Cucumber::Core::Test::Location.new(file, 19)
          filter = described_class.new([location])
          compile([doc], receiver, [filter])

          expect(receiver.test_case_locations).to eq([test_case_named('with docstring').location])
        end
      end

      context 'with a table' do
        let(:test_case) { test_cases.detect { |tc| tc.name == 'with a table' } }
        let(:starting_location) { Cucumber::Core::Test::Location.new(file, 23) }
        let(:midpoint_location) { Cucumber::Core::Test::Location.new(file, 24) }
        let(:ending_location) { Cucumber::Core::Test::Location.new(file, 25) }

        it 'matches a location at the start of the table' do
          filter = described_class.new([starting_location])
          compile([doc], receiver, [filter])
          expect(receiver.test_case_locations).to eq([test_case_named('with a table').location])
        end

        it 'matches a location at the middle of the table' do
          filter = described_class.new([midpoint_location])
          compile([doc], receiver, [filter])
          expect(receiver.test_case_locations).to eq([test_case_named('with a table').location])
        end

        it 'matches a location at the end of the table' do
          filter = described_class.new([ending_location])
          compile([doc], receiver, [filter])
          expect(receiver.test_case_locations).to eq([test_case_named('with a table').location])
        end
      end

      context 'with duplicate locations in the filter' do
        it 'matches each test case only once' do
          location_tc_two = test_case_named('two').location
          location_tc_one = test_case_named('one').location
          location_last_step_tc_two = Cucumber::Core::Test::Location.new(file, 12)
          filter = described_class.new([location_tc_two, location_tc_one, location_last_step_tc_two])
          compile([doc], receiver, [filter])
          expect(receiver.test_case_locations).to eq([test_case_named('two').location, test_case_named('one').location])
        end
      end
    end

    context 'with a scenario outline' do
      let(:doc) do
        Cucumber::Core::Gherkin::Document.new(file, <<-FEATURE)
        Feature:

          Scenario: one
            Given one a

          # comment on line 6
          @tag-on-line-7
          Scenario Outline: two <arg>
            Given two a
            And two <arg>
              """
              docstring
              """

            # comment on line 15
            @tag-on-line-16
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

      let(:test_case) { test_cases.detect { |tc| tc.name == 'two b' } }
      let(:feature_location) { Cucumber::Core::Test::Location.new(file, 1) }
      let(:row_location) { Cucumber::Core::Test::Location.new(file, 19) }
      let(:start_of_outline_location) { Cucumber::Core::Test::Location.new(file, 8) }
      let(:middle_of_outline_location) { Cucumber::Core::Test::Location.new(file, 10) }
      let(:outline_tags_location) { Cucumber::Core::Test::Location.new(file, 7) }

      it 'matches the feature line to all scenarios' do
        filter = described_class.new([feature_location])
        compile [doc], receiver, [filter]
        expect(receiver.test_case_locations).to eq(test_cases.map(&:location))
      end

      it 'matches row location to the test case of the row' do
        filter = described_class.new([row_location])
        compile([doc], receiver, [filter])
        expect(receiver.test_case_locations).to eq([test_case.location])
      end

      it 'matches outline location with the all test cases of all the tables' do
        filter = described_class.new([start_of_outline_location])
        compile([doc], receiver, [filter])
        expect(receiver.test_case_locations.map(&:line)).to eq([19, 23, 24])
      end

      it 'matches a location on a step of the scenario outline with all test cases of all the tables' do
        filter = described_class.new([middle_of_outline_location])
        compile([doc], receiver, [filter])
        expect(receiver.test_case_locations.map(&:line)).to eq([19, 23, 24])
      end

      it "matches a location on the scenario outline's tags with all test cases of all the tables" do
        filter = described_class.new([outline_tags_location])
        compile([doc], receiver, [filter])
        expect(receiver.test_case_locations.map(&:line)).to eq([19, 23, 24])
      end

      it "doesn't match the location of the examples line" do
        location = Cucumber::Core::Test::Location.new(file, 17)
        filter = described_class.new([location])
        compile([doc], receiver, [filter])
        expect(receiver.test_case_locations).to eq([])
      end
    end
  end

  context 'when under extreme load', :slow do
    let(:number_of_features) { 50 }
    let(:number_of_scenarios_per_feature) { 50 }
    let(:docs) do
      50.times.map do |feature_number|
        gherkin("features/test_#{feature_number}.feature") do
          feature do
            50.times.each do |scenario_number|
              scenario "scenario #{scenario_number}" do
                step 'text'
              end
            end
          end
        end
      end
    end
    let(:locations) do
      50.times.map do |feature_number|
        50.times.map do |scenario_number|
          scenario_line = 3 + (scenario_number * 3)
          Cucumber::Core::Test::Location.new("features/test_#{feature_number}.feature", scenario_line)
        end
      end.flatten
    end
    let(:max_duration_ms) { defined?(JRUBY_VERSION) ? 25_000 : 10_000 }

    it 'filters all test cases within an appropriate time' do
      filter = described_class.new(locations)
      Timeout.timeout(max_duration_ms / 1000.0) do
        compile(docs, receiver, [filter])
      end
      expect(receiver.test_cases.length).to eq(number_of_features * number_of_scenarios_per_feature)
    end
  end
end
