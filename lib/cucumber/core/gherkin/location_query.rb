# frozen_string_literal: true

# Note: this may move to cucumber-query later on

module Cucumber
  module Core
    module Gherkin
      class LocationQuery
        def process(message)
          if message.gherkinDocument
            process_gherkin_document(message.gherkinDocument)
          elsif message.pickle
            process_pickle(message.pickle)
          end
        end

        def pickles
          @pickles ||= []
        end

        def pickle_locations(pickle)
          scenario = scenario_by_id[pickle.sourceIds[0]]
          table_row = table_row_by_id[pickle.sourceIds[1]]
          locations = []

          locations << scenario.location if scenario
          locations << table_row.location if table_row
          locations
        end

        def pickle_step_locations(pickle_step)
          scenario_step = scenario_step_by_id[pickle_step.sourceIds[0]]
          table_row = table_row_by_id[pickle_step.sourceIds[1]]
          locations = []

          locations << scenario_step.location if scenario_step
          locations << table_row.location if table_row
          locations
        end

        def pickle_tag_location(pickle_tag)
          tag_by_id[pickle_tag.sourceId].location
        end

        private

        def process_gherkin_document(document)
          if document.feature
            process_children(document.feature.children)
            process_tags(document.feature.tags)
          end
        end

        def process_children(children)
          children.each do |children|
            process_scenario(children.scenario) if children.scenario
            process_children(children.rule.children) if children.rule
          end
        end

        def process_scenario(scenario)
          scenario_by_id[scenario.id] = scenario
          process_tags(scenario.tags)
          scenario.steps.each do |step|
            scenario_step_by_id[step.id] = step
          end
          process_examples(scenario.examples) if scenario.examples
        end

        def process_examples(examples)
          examples.each do |example|
            process_tags(example.tags)
            example.table_body.each do |table_row|
              table_row_by_id[table_row.id] = table_row
            end
          end
        end

        def process_tags(tags)
          tags.each do |tag|
            tag_by_id[tag.id] = tag
          end
        end

        def process_pickle(pickle)
          pickles << pickle
        end

        def scenario_by_id
          @scenario_by_id ||= {}
        end

        def scenario_step_by_id
          @scenario_step_by_id ||= {}
        end

        def table_row_by_id
          @table_row_by_id ||= {}
        end

        def tag_by_id
          @tag_by_id ||= {}
        end
      end
    end
  end
end