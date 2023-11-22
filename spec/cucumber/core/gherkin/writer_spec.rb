# frozen_string_literal: true

require 'cucumber/core/gherkin/writer'

describe Cucumber::Core::Gherkin::Writer do
  include described_class

  it 'generates a uri by default' do
    source = gherkin { feature }

    expect(source.uri).to eq 'features/test.feature'
  end

  it 'allows you to specify a URI' do
    source = gherkin('features/path/to/my.feature') { feature }

    expect(source.uri).to eq 'features/path/to/my.feature'
  end

  it 'generates the feature statement by default' do
    source = gherkin { feature }

    expect(source).to eq "Feature:\n"
  end

  context 'when a name is provided' do
    it 'includes the name in the feature statement' do
      source = gherkin do
        feature "A Feature\n"
      end

      expect(source).to eq "Feature: A Feature\n"
    end
  end

  context 'when a description is provided' do
    let(:expected) do
      <<~FEATURE
        Feature: A Feature
          This is the description
          which can span
          multiple lines.
      FEATURE
    end

    it 'includes the description in the feature statement' do
      source = gherkin do
        feature 'A Feature', description: <<~FEATURE
          This is the description
          which can span
          multiple lines.
        FEATURE
      end

      expect(source).to eq(expected)
    end
  end

  context 'when a keyword is provided' do
    it 'uses the supplied keyword' do
      source = gherkin do
        feature 'A Feature', keyword: 'Business Need'
      end

      expect(source).to eq("Business Need: A Feature\n")
    end
  end

  context 'when a language is supplied' do
    it 'inserts a language statement' do
      source = gherkin do
        feature language: 'ru'
      end

      expect(source).to eq("# language: ru\nFeature:\n")
    end
  end

  context 'when a comment is supplied' do
    it 'inserts a comment' do
      source = gherkin do
        comment 'wow'
        comment 'great'
        feature
      end

      expect(source.to_s).to eq "# wow\n# great\nFeature:\n"
    end
  end

  context 'with a scenario' do
    it 'includes the scenario statement' do
      source = gherkin do
        feature 'A Feature' do
          scenario
        end
      end

      expect(source.to_s).to match(/Scenario:/)
    end

    context 'when a comment is provided' do
      let(:expected) do
        <<~FEATURE
          Feature:

            # wow
            Scenario:
        FEATURE
      end

      it 'includes the comment in the scenario statement' do
        source = gherkin do
          feature do
            comment 'wow'
            scenario
          end
        end

        expect(source.to_s).to eq(expected)
      end
    end

    context 'when a description is provided' do
      let(:expected) do
        <<~FEATURE
          Feature:

            Scenario:
              This is the description
              which can span
              multiple lines.
        FEATURE
      end

      it 'includes the description in the scenario statement' do
        source = gherkin do
          feature do
            scenario description: <<~SCENARIO
              This is the description
              which can span
              multiple lines.
            SCENARIO
          end
        end

        expect(source).to eq(expected)
      end
    end

    context 'with a step' do
      it 'includes the step statement' do
        source = gherkin do
          feature 'A Feature' do
            scenario do
              step 'passing'
            end
          end
        end

        expect(source.to_s).to match(/Given passing\Z/m)
      end

      context 'when a docstring is provided' do
        let(:expected) do
          <<~FEATURE
            Feature:

              Scenario:
                Given failing
                  """text/plain
                  some text
                  """
          FEATURE
        end

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

          expect(source).to eq(expected)
        end
      end
    end
  end

  context 'with a background' do
    let(:expected) do
      <<~FEATURE
        Feature:

          Background:
            One line,
            and two..
      FEATURE
    end

    it 'can have a description' do
      source = gherkin do
        feature do
          background description: "One line,\nand two.."
        end
      end

      expect(source).to eq(expected)
    end
  end

  context 'with a scenario outline' do
    let(:expected) do
      <<~FEATURE
        Feature:

          Scenario Outline:
            Doesn't need to be multi-line.
      FEATURE
    end

    it 'can have a description' do
      source = gherkin do
        feature do
          scenario_outline description: "Doesn't need to be multi-line."
        end
      end

      expect(source).to eq(expected)
    end

    context 'with an examples table' do
      let(:expected) do
        <<~FEATURE
          Feature:

            Scenario Outline:

              Examples:
                Doesn't need to be multi-line.
        FEATURE
      end

      it 'can have a description' do
        source = gherkin do
          feature do
            scenario_outline do
              examples description: "Doesn't need to be multi-line."
            end
          end
        end

        expect(source).to eq(expected)
      end
    end
  end

  it 'can generate a complex feature' do
    source = gherkin do
      comment 'wow'
      feature 'Fully featured', language: 'en', tags: '@always' do
        comment 'cool'
        background do
          step 'passing'
        end

        scenario do
          step 'passing'
        end

        comment 'here'
        scenario 'with doc string', tags: '@first @second' do
          comment 'and here'
          step 'passing'
          step 'failing', keyword: 'When' do
            doc_string <<~DOC_STRING
              I wish I was a little bit taller.
              I wish I was a baller.
            DOC_STRING
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

        comment 'yay'
        scenario_outline 'eating' do
          step 'there are <start> cucumbers'
          step 'I eat <eat> cucumbers', keyword: 'When'
          step 'I should have <left> cucumbers', keyword: 'Then'

          comment 'hmmm'
          examples do
            row 'start', 'eat', 'left'
            row '12',    '5',   '7'
            row '20',    '5',   '15'
          end
        end
      end
    end

    expected = <<~FEATURE
    # language: en
    # wow
    @always
    Feature: Fully featured

      # cool
      Background:
        Given passing

      Scenario:
        Given passing

      # here
      @first @second
      Scenario: with doc string
        # and here
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

      # yay
      Scenario Outline: eating
        Given there are <start> cucumbers
        When I eat <eat> cucumbers
        Then I should have <left> cucumbers

        # hmmm
        Examples:
          | start | eat | left |
          | 12    | 5   | 7    |
          | 20    | 5   | 15   |
    FEATURE

    expect(source.to_s).to eq(expected)
  end
end
