require 'cucumber/core'

module Cucumber
  module Core
    describe DSL do
      include DSL
      describe "parsing gherkin" do

        it "parses a feature with a single scenario" do
          feature = parse_gherkin %{Feature: Feature name
                                      Scenario: Scenario name
                                        Given passing
          }
          feature.name.should == 'Feature name'
        end

        it "parses a feature with a background" do
          feature = parse_gherkin %{Feature: Feature name
                                      Background: Background name
                                        Given passing

                                      Scenario: Scenario name
                                        Given passing
          }
          feature.name.should == 'Feature name'
        end
      end

      describe "compiling a test suite" do
        it "compiles two scenarios into two test cases" do
          feature = parse_gherkin %{Feature: Feature name
                                      Background: Background name
                                        Given passing

                                      Scenario: Scenario name 1
                                        Given passing

                                      Scenario: Scenario name 2
                                        Given passing
          }
          suite = compile([feature])
          suite.test_cases.count.should == 2
        end

      end
    end
  end
end
