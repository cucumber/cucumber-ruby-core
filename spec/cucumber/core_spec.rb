require 'cucumber/core'
require 'cucumber/core/generates_gherkin'
require 'cucumber/core/platform'

module Cucumber
  describe Core do
    include Core
    include Core::GeneratesGherkin

    describe "parsing gherkin" do

      # String -> Gherkin::Parser -> Core::Ast::GherkinBuilder -> Ast objects

      it "parses valid gherkin, returning an Ast::Feature" do
        feature = parse_gherkin(
          gherkin do
            feature 'Feature name' do
              background 'Background name' do
                step 'passing'
              end
              scenario do
                step 'passing'
              end
            end
          end
        )
        feature.should be_a(Core::Ast::Feature)
        feature.name.should == 'Feature name'
      end

      it "raises an error when parsing invalid gherkin" do
        expected_error = if Cucumber::JRUBY
                           gherkin::lexer::lexingError
                         else
                           Gherkin::Lexer::LexingError
                         end
        expect { parse_gherkin('not gherkin') }.
          to raise_error(expected_error)
      end


    end

    describe "compiling features to a test suite" do
      it "compiles two scenarios into two test cases" do
        feature = parse_gherkin(
          gherkin do
            feature do
              background do
                step
              end
              scenario do
                step
              end
              scenario do
                step
                step
              end
            end
          end
        )

        suite = compile([feature])
        visitor = stub
        visitor.should_receive(:test_suite).once.and_yield.ordered
        visitor.should_receive(:test_case).exactly(2).times.and_yield.ordered
        visitor.should_receive(:test_step).exactly(5).times.ordered
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
        feature = parse_gherkin(
          gherkin do
            feature 'Feature name' do
              scenario 'The one that passes' do
                step 'passing'
              end

              scenario 'The one that fails' do
                step 'passing'
                step 'failing'
              end
            end
          end
        )
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
