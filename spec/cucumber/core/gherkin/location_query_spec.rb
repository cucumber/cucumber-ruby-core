# -*- encoding: utf-8 -*-
# frozen_string_literal: true
require 'cucumber/core/gherkin/location_query'
require 'gherkin'

module Cucumber
  module Core
    module Gherkin
      describe LocationQuery do
        let(:subject) {
          lq = LocationQuery.new
          messages.each do |message|
            lq.process(message)
          end
          lq
        }

        let(:content) {
          <<-FEATURE
            Feature: my simple feature

            Scenario: A scenario
              Given a passed step
            FEATURE
        }

        let(:messages) { ::Gherkin.from_source(
          'some.feature',
          content, {
            include_gherkin_document: true,
            include_pickles: true
          }
        )}

        let(:pickle) {
          subject.pickles.first
        }

        describe 'pickle_locations' do
          it 'returns the Location of source scenario' do
            location = subject.pickle_locations(pickle).first

            expect(location.line).to eq(3)
          end

          context 'when generated from a Examples table' do
            let(:content) {
              <<-FEATURE
                Feature: my simple feature

                Scenario: A scenario
                  Given a <status> step

                Examples:
                   | status |
                   | passed |
                   | failed |
                FEATURE
            }

            it 'returns the Locations of the source scenario and example used' do
              locations = subject.pickle_locations(pickle)

              expect(locations[0].line).to eq(3)
              expect(locations[1].line).to eq(8)
            end
          end
        end

        describe 'pickle_step_locations' do
          let(:pickle_step) { pickle.steps.first }

          it 'returns the Location of the scenario step' do
            expect(subject.pickle_step_locations(pickle_step).first.line).to eq(4)
          end

          context 'when generated from a Examples table' do
            let(:content) {
              <<-FEATURE
                Feature: my simple feature

                Scenario: A scenario
                  Given a <status> step

                Examples:
                   | status |
                   | passed |
                   | failed |
                FEATURE
            }

            it 'returns the Locations of the scenario step and example used' do
              locations = subject.pickle_step_locations(pickle_step)

              expect(locations[0].line).to eq(4)
              expect(locations[1].line).to eq(8)
            end
          end
        end

        describe 'pickle_tag_location' do
          let(:content) {
            <<-FEATURE
            Feature:  With tags

              @acceptance
              Scenario: With a single tag
                Given a passed step
              FEATURE
          }
          let(:pickle_tag) { pickle.tags.first }

          it 'returns the Location of the tag' do
            expect(subject.pickle_tag_location(pickle_tag).line).to eq(3)
          end
        end
      end
    end
  end
end