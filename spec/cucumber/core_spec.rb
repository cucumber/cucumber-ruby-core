require 'report_api_spy'
require 'cucumber/core'
require 'cucumber/core/gherkin/writer'
require 'cucumber/core/platform'
require 'cucumber/core/report/summary'

module Cucumber
  describe Core do
    include Core
    include Core::Gherkin::Writer

    describe "compiling features to a test suite" do

      it "compiles two scenarios into two test cases" do
        visitor = ReportAPISpy.new

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

        expect( visitor.messages ).to eq [
          :test_case,
          :test_step,
          :test_step,
          :test_case,
          :test_step,
          :test_step,
          :test_step,
          :done,
        ]
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
          report = Core::Report::Summary.new
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
          attr_reader :logger

          def initialize
            @logger = []
          end

          def test_case(test_case, mapper)
            mapper.before { @logger << ['--'] }
            failing_before = proc do
              @logger << [:failing_before, test_case.name]
              raise Failure
            end
            passing_after = proc do
              @logger << [:passing_after, test_case.name]
            end
            passing_before = proc do 
              @logger << [:passing_before, test_case.name]
            end
            failing_after = proc do
              @logger << [:failing_after, test_case.name]
              raise Failure
            end

            case test_case.name

            when /fail before/
              mapper.before( &failing_before )
              mapper.after( &passing_after )

            when /fail after/
              mapper.before( &passing_before )
              mapper.after( &failing_after )

            else
              mapper.before( &passing_before )
              mapper.after( &passing_after )

            end

            self
          end

          def test_step(test_step, mapper)
            mapper.map { @logger << [:step, test_step.name] } # all steps pass
            if test_step.name == 'fail after'
              mapper.after do
                @logger << :failing_after_step
                raise Failure 
              end
            end
            self
          end
        end

        it "executes the steps and hooks in the right order" do
          gherkin = gherkin do
            feature do
              scenario 'fail before' do
                step 'passing'
              end

              scenario 'fail after' do
                step 'passing'
              end

              scenario 'fail step' do
                step 'fail after'
              end

              scenario 'passing' do
                step 'passing'
              end
            end
          end
          report = Core::Report::Summary.new
          mappings = HookTestMappings.new

          execute [gherkin], mappings, report

          expect( report.test_steps.total        ).to eq(17)
          expect( report.test_steps.total_failed ).to eq(3)
          expect( report.test_cases.total        ).to eq(4)
          expect( report.test_cases.total_passed ).to eq(1)
          expect( report.test_cases.total_failed ).to eq(3)
          expect( mappings.logger ).to eq [
            ["--"], 
            [:failing_before, "Scenario: fail before"], 
            [:passing_after, "Scenario: fail before"],
            ["--"], 
            [:passing_before, "Scenario: fail after"], 
            [:step, "passing"],
            [:failing_after, "Scenario: fail after"],
            ["--"],
            [:passing_before, "Scenario: fail step"],
            [:step, "fail after"],
            :failing_after_step,
            [:passing_after, "Scenario: fail step"],
            ["--"],
            [:passing_before, "Scenario: passing"],
            [:step, "passing"],
            [:passing_after, "Scenario: passing"]
          ]
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
              logger << :before_all
              run_scenario.call
              logger << :middle
              run_scenario.call
              logger << :after_all
            end
            mapper.before do
              logger << :before
            end
            mapper.after do
              logger << :after
            end
            self
          end

          def test_step(step, mapper)
            logger = @logger
            mapper.map do
              logger << :during
            end
            mapper.after do
              logger << :after_step
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
          report = Core::Report::Summary.new
          mappings = AroundHookTestMappings.new

          execute [gherkin], mappings, report

          expect( report.test_cases.total        ).to eq 1
          expect( report.test_cases.total_passed ).to eq 1
          expect( report.test_cases.total_failed ).to eq 0
          expect( mappings.logger ).to eq [
            :before_all, 
              :before, 
                :during, 
                :after_step, 
              :after, 
            :middle, 
              :before,
                :during, 
                :after_step, 
              :after,
            :after_all
          ]
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
        report = Core::Report::Summary.new
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
        report = Core::Report::Summary.new
        mappings = HookTestMappings.new

        execute [gherkin], mappings, report, [[Cucumber::Core::Test::NameFilter, [[/scenario/]]]]

        expect( report.test_cases.total ).to eq 1
      end
    end
  end
end
