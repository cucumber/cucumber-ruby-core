require 'cucumber/core'
require 'cucumber/core/gherkin/writer'
require 'cucumber/core/platform'

module Cucumber
  describe Core do
    include Core
    include Core::Gherkin::Writer

    describe "parsing Gherkin" do
      it "calls the compiler with a valid AST" do
        compiler = double(done: nil)
        expect( compiler ).to receive(:feature) do |feature|
          expect( feature ).to respond_to(:describe_to)
          expect( feature ).to be_an_instance_of(Core::Ast::Feature)
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
        expect( visitor ).to receive(:test_case).exactly(2).times.and_yield.ordered
        expect( visitor ).to receive(:test_step).exactly(5).times.ordered
        expect( visitor ).to receive(:done).once.ordered

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
        expect( visitor ).to receive(:test_case) do |test_case|
          expect( test_case.name ).to eq 'Scenario Outline: foo, bar (row 1)'
        end.exactly(1).times

        gherkin = gherkin do
          feature do
            scenario tags: '@b' do
              step
            end

            scenario_outline 'foo' do
              step '<arg>'

              examples tags: '@a'do
                row 'arg'
                row 'x'
              end

              examples 'bar', tags: '@a @b' do
                row 'arg'
                row 'y'
              end
            end
          end
        end

        compile [gherkin], visitor, [[Cucumber::Core::Test::TagFilter, [['@a', '@b']]]]
      end

      describe 'with tag filters that have limits' do
        let(:visitor) { double.as_null_object }
        let(:gherkin_doc) do
          gherkin do
            feature tags: '@feature' do
              scenario tags: '@one @three' do
                step
              end

              scenario tags: '@one' do
                step
              end

              scenario_outline  do
                step '<arg>'

                examples tags: '@three'do
                  row 'arg'
                  row 'x'
                end
              end

              scenario tags: '@ignore' do
                step
              end
            end
          end
        end

        require 'unindent'
        def expect_tag_excess(error_message)
          expect {
            compile [gherkin_doc], visitor, tag_filters
          }.to raise_error(
            Cucumber::Core::Test::TagFilter::TagExcess, error_message.unindent.chomp
          )
        end

        context 'on scenarios' do
          let(:tag_filters) {
            [[Cucumber::Core::Test::TagFilter, [['@one:1']]]]
          }

          it 'raises a tag excess error with the location of the test cases' do
            expect_tag_excess <<-STR
              @one occurred 2 times, but the limit was set to 1
                features/test.feature:5
                features/test.feature:9
            STR
          end
        end

        context 'on scenario outlines' do
          let(:tag_filters) {
            [[Cucumber::Core::Test::TagFilter, [['@three:1']]]]
          }

          it 'raises a tag excess error with the location of the test cases' do
            expect_tag_excess <<-STR
              @three occurred 2 times, but the limit was set to 1
                features/test.feature:5
                features/test.feature:18
            STR
          end
        end

        context 'on a feature with scenarios' do
          let(:tag_filters) {
            [[Cucumber::Core::Test::TagFilter, [['@feature:2']]]]
          }

          it 'raises a tag excess error with the location of the test cases' do
            expect_tag_excess <<-STR
              @feature occurred 4 times, but the limit was set to 2
                features/test.feature:5
                features/test.feature:9
                features/test.feature:18
                features/test.feature:21
            STR
          end
        end

        context 'with negated tags' do
          let(:tag_filters) {
            [[Cucumber::Core::Test::TagFilter, [['~@one:1']]]]
          }

          it 'raises a tag excess error with the location of the test cases' do
            expect_tag_excess <<-STR
              @one occurred 2 times, but the limit was set to 1
                features/test.feature:5
                features/test.feature:9
            STR
          end
        end

        context 'whith multiple tag limits' do
          let(:tag_filters) {
            [[Cucumber::Core::Test::TagFilter, [['@one:1, @three:1', '~@feature:3']]]]
          }

          it 'raises a tag excess error with the location of the test cases' do
            expect_tag_excess <<-STR
              @one occurred 2 times, but the limit was set to 1
                features/test.feature:5
                features/test.feature:9
              @three occurred 2 times, but the limit was set to 1
                features/test.feature:5
                features/test.feature:18
              @feature occurred 4 times, but the limit was set to 3
                features/test.feature:5
                features/test.feature:9
                features/test.feature:18
                features/test.feature:21
            STR
          end
        end

      end

    end

    describe "executing a test suite" do
      class SummaryReport
        attr_reader :test_cases, :test_steps

        def initialize
          @test_cases = Core::Test::Result::Summary.new
          @test_steps = Core::Test::Result::Summary.new
        end

        def before_test_case(*)
          yield if block_given?
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

          expect( report.test_cases.total           ).to eq 2
          expect( report.test_cases.total_passed    ).to eq 1
          expect( report.test_cases.total_failed    ).to eq 1
          expect( report.test_steps.total           ).to eq 5
          expect( report.test_steps.total_failed    ).to eq 1
          expect( report.test_steps.total_passed    ).to eq 2
          expect( report.test_steps.total_skipped   ).to eq 1
          expect( report.test_steps.total_undefined ).to eq 1
        end
      end

      context "with hooks" do
        class HookTestMappings
          Failure = Class.new(StandardError)

          def test_case(test_case, mapper)
            case test_case.name
            when /fail before/
              mapper.before { raise Failure }
              mapper.after  { 'This hook will be skipped' }
            when /fail after/
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

          expect( report.test_steps.total        ).to eq(6)
          expect( report.test_steps.total_failed ).to eq(2)
          expect( report.test_cases.total        ).to eq(3)
          expect( report.test_cases.total_passed ).to eq(1)
          expect( report.test_cases.total_failed ).to eq(2)
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
            mapper.around do |run_scenario|
              logger << :before
              run_scenario.call
              logger << :middle
              run_scenario.call
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

          expect( report.test_cases.total        ).to eq 1
          expect( report.test_cases.total_passed ).to eq 1
          expect( report.test_cases.total_failed ).to eq 0
          expect( mappings.logger ).to eq [:before, :during, :middle, :during, :after]
        end
      end

      require 'cucumber/core/test/filters'
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

        expect( report.test_cases.total ).to eq 2
      end

      it "filters test cases by name" do
        gherkin = gherkin do
          feature 'first feature' do
            scenario 'first scenario' do
              step 'missing'
            end
            scenario 'second' do
              step 'missing'
            end
          end
        end
        report = SummaryReport.new
        mappings = HookTestMappings.new

        execute [gherkin], mappings, report, [[Cucumber::Core::Test::NameFilter, [[/scenario/]]]]

        expect( report.test_cases.total ).to eq 1
      end
    end
  end
end
