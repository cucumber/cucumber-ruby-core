require 'cucumber/core/generates_gherkin'
require 'unindent'

module Cucumber
  module Core
    describe GeneratesGherkin do
      include GeneratesGherkin

      context 'a feature' do

        it 'generates the feature statement' do
          source = gherkin { feature }
          source.should == "Feature:\n"
        end

        context 'when a name is provided' do
          it 'includes the name in the feature statement' do
            source = gherkin do
              feature "A Feature\n"
            end
            source.should == "Feature: A Feature\n"
          end
        end

        context 'when a description is provided' do
          it 'includes the description in the feature statement' do
            source = gherkin do
              feature "A Feature", description: <<-END
                This is the description
                which can span
                multiple lines.
                END
            end
            expected = <<-END
            Feature: A Feature
              This is the description
              which can span
              multiple lines.
            END

            source.should == expected.unindent
          end
        end

        context 'when a keyword is provided' do
          it 'uses the supplied keyword' do
            source = gherkin do
              feature "A Feature", keyword: "Business Need"
            end
            source.should == "Business Need: A Feature\n"
          end
        end

        context 'when a language is supplied' do
          it 'inserts a language statement' do
            source = gherkin do
              feature language: 'ru'
            end

            source.should == "# language: ru\nFeature:\n"
          end
        end

        context 'with a scenario' do
          it 'includes the scenario statement' do
            source = gherkin do
              feature "A Feature" do
                scenario
              end
            end

            source.should =~ /Scenario:/
          end

          context 'when a description is provided' do
            it 'includes the description in the scenario statement' do
              source = gherkin do
                feature do
                  scenario description: <<-END
                    This is the description
                    which can span
                    multiple lines.
                    END
                end
              end

              source.should == <<-END.unindent
              Feature:

                Scenario:
                  This is the description
                  which can span
                  multiple lines.
              END
            end
          end

          context 'with a step' do
            it 'includes the step statement' do
              source = gherkin do
                feature "A Feature" do
                  scenario do
                    step 'passing'
                  end
                end
              end

              source.should =~ /Given passing\Z/m
            end

            context 'when a docstring is provided' do
              it 'includes the content type when provided' do
                source = gherkin do
                  feature do
                    scenario do
                      step 'failing' do
                        doc_string 'some text', 'text/plain'
                      end
                    end
                  end

                end

                source.should == <<-END.unindent
                Feature:

                  Scenario:
                    Given failing
                      """text/plain
                      some text
                      """
                END
              end
            end
          end
        end

        context 'with a background' do
          it 'can have a description' do
            source = gherkin do
              feature do
                background description: "One line,\nand two.."
              end
            end

            source.should == <<-END.unindent
            Feature:

              Background:
                One line,
                and two..
            END
          end
        end

        context 'with a scenario outline' do
          it 'can have a description' do
            source = gherkin do
              feature do
                scenario_outline description: "Doesn't need to be multi-line."
              end
            end

            source.should == <<-END.unindent
            Feature:

              Scenario Outline:
                Doesn't need to be multi-line.
            END
          end

          context 'and examples table' do
            it 'can have a description' do
              source = gherkin do
                feature do
                  scenario_outline do
                    examples description: "Doesn't need to be multi-line." do

                    end
                  end
                end
              end

              source.should == <<-END.unindent
              Feature:

                Scenario Outline:

                  Examples:
                    Doesn't need to be multi-line.
              END
            end
          end
        end
      end

      it 'generates a complex feature' do
        source = gherkin do
          feature 'Fully featured', language: 'en', tags: '@always' do
            background do
              step 'passing'
            end

            scenario do
              step 'passing'
            end

            scenario 'with doc string', tags: '@first @second' do
              step 'passing'
              step 'failing', keyword: 'When' do
                doc_string <<-END
                I wish I was a little bit taller.
                I wish I was a baller.
                END
              end
            end

            scenario 'with a table...' do
              step 'passes:' do
                table do
                  row 'name',   'age', 'location'
                  row 'Janine', '43',  'Antarctica'
                end
              end
            end

            scenario_outline 'eating' do
              step 'there are <start> cucumbers'
              step 'I eat <eat> cucumbers', keyword: 'When'
              step 'I should have <left> cucumbers', keyword: 'Then'

              examples do
                row 'start', 'eat', 'left'
                row '12',    '5',   '7'
                row '20',    '5',   '15'
              end
            end
          end
        end

        expected = <<-END
        # language: en
        @always
        Feature: Fully featured

          Background:
            Given passing

          Scenario:
            Given passing

          @first @second
          Scenario: with doc string
            Given passing
            When failing
              """
              I wish I was a little bit taller.
              I wish I was a baller.
              """

          Scenario: with a table...
            Given passes:
              | name   | age | location   |
              | Janine | 43  | Antarctica |

          Scenario Outline: eating
            Given there are <start> cucumbers
            When I eat <eat> cucumbers
            Then I should have <left> cucumbers

            Examples:
              | start | eat | left |
              | 12    | 5   | 7    |
              | 20    | 5   | 15   |
        END

        source.should == expected.unindent
      end
    end
  end
end
