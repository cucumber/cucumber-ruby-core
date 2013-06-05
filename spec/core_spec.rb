require 'cucumber/core'

module Cucumber
  describe Core do
    include Core
    describe "parsing gherkin" do

      # String -> Gherkin::Parser -> Core::Ast::GherkinBuilder -> Ast objects

      it "raises an error when parsing invalid gherkin" do
        expect { parse_gherkin('not gherkin') }.
          to raise_error(Gherkin::Lexer::LexingError)
      end

      it "parses valid gherkin" do
        feature = parse_gherkin %{Feature: Feature name
                                      Background: Background name
                                        Given passing

                                      Scenario: Scenario name
                                        Given passing
        }
        feature.name.should == 'Feature name'
      end

      it "sets the language from the Gherkin" do
        feature = parse_gherkin %{# language: ja
                機能: Feature name
        }
        feature.language.iso_code.should == 'ja'
      end
    end

    describe "compiling a test suite" do
      it "compiles two scenarios into two test cases" do
        feature = parse_gherkin %{Feature: Feature name
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
