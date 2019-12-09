# frozen_string_literal: true

require 'cucumber/core/test/case'
require 'cucumber/core/test/step'
require 'cucumber/core/test/tag'
require 'cucumber/core/test/doc_string'
require 'cucumber/core/test/data_table'
require 'cucumber/core/test/empty_multiline_argument'

module Cucumber
  module Core
    # Compiles the Pickles into test cases
    class Compiler
      attr_reader :receiver
      private     :receiver

      def initialize(receiver)
        @receiver = receiver
      end

      def pickle(pickle, location_query)
        test_case = create_test_case(pickle, location_query)
        test_case.describe_to(receiver)
      end

      def done
        receiver.done
        self
      end

      private

      def create_test_case(pickle, location_query)
        uri = pickle.uri
        lines = location_query.pickle_locations(pickle).map do |location|
          location.line
        end.sort.reverse

        test_steps = pickle.steps.map { |step| create_test_step(step, uri, location_query) }

        tags = pickle.tags.map do |tag|
          Test::Tag.new(
            Test::Location.new(uri, location_query.pickle_tag_location(tag).line),
            tag.name
          )
        end

        Test::Case.new(
          pickle.id,
          pickle.name,
          test_steps,
          Test::Location.new(uri, lines),
          tags,
          pickle.language,
          [])
      end

      def create_test_step(pickle_step, uri, location_query)
        lines = location_query.pickle_step_locations(pickle_step).map do |location|
          location.line
        end.sort.reverse

        multiline_arg = create_multiline_arg(pickle_step, uri, location_query)
        Test::Step.new(
          pickle_step.id,
          pickle_step.text,
          Test::Location.new(uri, lines),
          multiline_arg,
          nil
        )
      end

      def create_multiline_arg(pickle_step, uri, location_query)
        argumentLocation = location_query.pickle_step_argument_location(pickle_step)
        line = argumentLocation ? argumentLocation.line : 0

        if pickle_step.argument
          if pickle_step.argument.doc_string
            doc_string = pickle_step.argument.doc_string
            Test::DocString.new(
              doc_string.content,
              doc_string.content_type,
              Test::Location.new(uri, line)
            )
          elsif pickle_step.argument.data_table
            data_table = pickle_step.argument.data_table
            Test::DataTable.new(
              data_table.rows.map { |row| row.cells.map { |cell| cell.value } },
              Test::Location.new(uri, line)
            )
          end
        else
          Test::EmptyMultilineArgument.new
        end
      end
    end
  end
end
