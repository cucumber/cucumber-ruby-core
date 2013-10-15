require 'cucumber/core'
require 'cucumber/core/gherkin/writer'
require 'cucumber/core/platform'

module Cucumber
  describe Core do
    include Core
    include Core::Gherkin::Writer

    describe "parsing Gherkin" do
      it "calls the compiler with a valid AST" do
        compiler = double
        compiler.should_receive(:feature) do |feature|
          feature.should respond_to(:describe_to)
        end

        gherkin = gherkin do
          feature do
            scenario do
              step
            end
          end
        end

        parse([gherkin], compiler)
      end
    end

    describe "compiling features to a test suite" do
      it "compiles two scenarios into two test cases" do
        visitor = double
        visitor.should_receive(:test_case).exactly(2).times.and_yield.ordered
        visitor.should_receive(:test_step).exactly(5).times.ordered

        compile([
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
        ], visitor)
      end

      it "filters out test cases based on a tag expression" do
        visitor = double.as_null_object
        visitor.should_receive(:test_case).exactly(1).times

        gherkin = gherkin do
          feature do
            scenario tags: '@a' do
              step
            end

            scenario_outline do
              step '<arg>'

              examples do
                row 'arg'
                row 'x'
              end

              examples tags: '@a' do
                row 'arg'
                row 'y'
              end
            end
          end
        end

        compile [gherkin], visitor, [[Cucumber::Core::Test::TagFilter, ['~@a']]]
      end
    end

    describe "executing a test suite" do
      class SummaryReport
        attr_reader :test_cases, :test_steps

        def initialize
          @test_cases = Core::Test::Result::Summary.new
          @test_steps = Core::Test::Result::Summary.new
        end

        def after_test_case(test_case, result)
          result.describe_to test_cases
        end

        def after_test_step(test_step, result)
          result.describe_to test_steps
        end

        def method_missing(*)
        end
      end

      context "without hooks" do
        class StepTestMappings
          Failure = Class.new(StandardError)

          def test_case(test_case, mapper)
            self
          end

          def test_step(step, mapper)
            mapper.map { raise Failure } if step.name =~ /fail/
            mapper.map {}                if step.name =~ /pass/
            self
          end
        end

        it "executes the test cases in the suite" do
          gherkin = gherkin do
            feature 'Feature name' do
              scenario 'The one that passes' do
                step 'passing'
              end

              scenario 'The one that fails' do
                step 'passing'
                step 'failing'
                step 'passing'
                step 'undefined'
              end
            end
          end
          report = SummaryReport.new
          mappings = StepTestMappings.new

          execute [gherkin], mappings, report

          report.test_cases.total.should eq(2)
          report.test_cases.total_passed.should eq(1)
          report.test_cases.total_failed.should eq(1)
          report.test_steps.total.should eq(5)
          report.test_steps.total_failed.should eq(1)
          report.test_steps.total_passed.should eq(2)
          report.test_steps.total_skipped.should eq(1)
          report.test_steps.total_undefined.should eq(1)
        end
      end

      context "with hooks" do
        class HookTestMappings
          Failure = Class.new(StandardError)

          def test_case(test_case, mapper)
            case test_case.name
            when 'fail before'
              mapper.before { raise Failure }
              mapper.after  { 'This hook will be skipped' }
            when 'fail after'
              mapper.after { raise Failure }
            end
            self
          end

          def test_step(step, mapper)
            mapper.map {} # all steps pass
            self
          end
        end

        it "executes the test cases in the suite" do
          gherkin = gherkin do
            feature do
              scenario 'fail before' do
                step 'passing'
              end

              scenario 'fail after' do
                step 'passing'
              end

              scenario 'passing' do
                step 'passing'
              end
            end
          end
          report = SummaryReport.new
          mappings = HookTestMappings.new

          execute [gherkin], mappings, report

          report.test_cases.total.should eq(3)
          report.test_cases.total_passed.should eq(1)
          report.test_cases.total_failed.should eq(2)
          report.test_steps.total.should eq(6)
          report.test_steps.total_failed.should eq(2)
        end
      end

      context "with around hooks" do
        class AroundHookTestMappings
          attr_reader :logger

          def initialize
            @logger = []
          end

          def test_case(test_case, mapper)
            logger = @logger
            mapper.around do |continue|
              logger << :before
              continue.call
              logger << :after
            end
            self
          end

          def test_step(step, mapper)
            logger = @logger
            mapper.map do
              logger << :during
            end
            self
          end
        end

        it "executes the test cases in the suite" do
          gherkin = gherkin do
            feature do
              scenario do
                step
              end
            end
          end
          report = SummaryReport.new
          mappings = AroundHookTestMappings.new

          execute [gherkin], mappings, report

          report.test_cases.total.should eq(1)
          report.test_cases.total_passed.should eq(1)
          report.test_cases.total_failed.should eq(0)
          mappings.logger.should == [:before, :during, :after]
        end
      end

      require 'cucumber/core/test/tag_filter'
      it "filters test cases by tag" do
        gherkin = gherkin do
          feature do
            scenario do
              step
            end

            scenario tags: '@a @b' do
              step
            end

            scenario tags: '@a' do
              step
            end
          end
        end
        report = SummaryReport.new
        mappings = HookTestMappings.new

        execute [gherkin], mappings, report, [[Cucumber::Core::Test::TagFilter, ['@a']]]

        report.test_cases.total.should eq(2)
      end
    end
  end
end
