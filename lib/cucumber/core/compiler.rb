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
      attr_reader :receiver, :id_generator
      private     :receiver, :id_generator

      def initialize(receiver, id_generator)
        @receiver = receiver
        @id_generator = id_generator
      end

      def pickle(pickle)
        test_case = create_test_case(pickle)
        test_case.describe_to(receiver)
      end

      def done
        receiver.done
        self
      end

      private

      def create_test_case(pickle)
        uri = pickle.uri
        test_steps = pickle.steps.map { |step| create_test_step(step, uri) }
        lines = pickle.locations.map { |location| location.line }.sort.reverse
        tags = pickle.tags.map { |tag| Test::Tag.new(Test::Location.new(uri, tag.location.line), tag.name) }
        Test::Case.new(id_generator.new_id, pickle.name, test_steps, Test::Location.new(uri, lines), tags, pickle.language)
      end

      def create_test_step(pickle_step, uri)
        lines = pickle_step.locations.map { |location| location.line }.sort.reverse
        multiline_arg = create_multiline_arg(pickle_step, uri)
        Test::Step.new(id_generator.new_id, pickle_step.text, Test::Location.new(uri, lines), multiline_arg)
      end

      def create_multiline_arg(pickle_step, uri)
        if pickle_step.argument
          if pickle_step.argument.doc_string
            doc_string = pickle_step.argument.doc_string
            Test::DocString.new(
              doc_string.content,
              doc_string.contentType,
              Test::Location.new(uri, doc_string.location.line)
            )
          elsif pickle_step.argument.data_table
            data_table = pickle_step.argument.data_table
            first_cell = data_table.rows.first.cells.first
            Test::DataTable.new(
              data_table.rows.map { |row| row.cells.map { |cell| cell.value } },
              Test::Location.new(uri, first_cell.location.line)
            )
          end
        else
          Test::EmptyMultilineArgument.new
        end
      end
    end
  end
end
