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
        class Summary
          attr_reader :total_failed, :total_passed

          def initialize
            @total_failed = @total_passed = 0
          end

          def failed(*args)
            @total_failed += 1
          end

          def passed(*args)
            @total_passed += 1
          end

          def total
            total_passed + total_failed
          end
        end

        def initialize
          @test_case_summary = Summary.new
          @test_step_summary = Summary.new
        end

        def test_cases
          @test_case_summary
        end

        def test_steps
          @test_step_summary
        end

        def before_test_case(test_case)
        end

        def after_test_case(test_case, result)
          result.describe_to(@test_case_summary)
        end

        def before_test_step(test_step)
        end

        def after_test_step(test_step, result)
          result.describe_to(@test_step_summary)
        end
      end


      class FakeMappings
        Failure = Class.new(StandardError)

        def execute(step)
          raise Failure if step.name =~ /fail/
        end
      end

      it "executes the test cases in the suite" do
        feature = parse_gherkin %{Feature: Feature name
        Scenario: The one that passes
          Given passing

        Scenario: The one that fails
          Given passing
          Given failing
        }

        test_suite = compile([feature])
        report = ReportSpy.new
        mappings = FakeMappings.new

        execute(test_suite, mappings, report)

        report.test_cases.total.should == 2
        report.test_cases.total_passed.should == 1
        report.test_cases.total_failed.should == 1
        report.test_steps.total.should == 3
        report.test_steps.total_passed.should == 2
        report.test_steps.total_failed.should == 1
      end
    end
  end
end
