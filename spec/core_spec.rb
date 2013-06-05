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

    describe "compiling features to a test suite" do
      it "compiles two scenarios into two test cases" do
        feature = parse_gherkin %{Feature: Feature name
                                      Scenario: Scenario name 1
                                        Given passing

                                      Scenario: Scenario name 2
                                        Given passing
                                        When failing
        }
        suite = compile([feature])
        visitor = stub
        visitor.should_receive(:test_suite).once.and_yield
        visitor.should_receive(:test_case).exactly(2).times.and_yield
        visitor.should_receive(:test_step).exactly(3).times
        suite.describe_to(visitor)
      end

    end

    describe "executing a test suite" do
      class ReportSpy
        def initialize
          @total_test_cases = 0
        end

        def before_test_case(test_case)

        end

        def after_test_case(test_case)
          @total_test_cases += 1
        end

        def total_test_cases
          @total_test_cases
        end

        def total_passed_test_cases
          0
        end

        def total_failed_test_cases
          0
        end
      end

      it "executes the test cases in the suite" do
        feature = parse_gherkin %{Feature: Feature name
        Scenario: The one that passes
          Given passing

        Scenario: The one that fails
          Given failing
        }

        test_suite = compile([feature])
        report = ReportSpy.new
        mappings = stub

        execute(test_suite, mappings, report)

        report.total_test_cases.should == 2
        report.total_passed_test_cases.should == 1
        report.total_failed_test_cases.should == 1
      end
    end
  end
end
