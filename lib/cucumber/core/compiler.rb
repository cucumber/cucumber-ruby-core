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
        uri = pickle[:uri]
        test_steps = pickle[:steps].map { |step| create_test_step(step, uri) }
        lines = pickle[:locations].map { |location| location[:line] }.sort.reverse
        tags = pickle[:tags].map { |tag| Test::Tag.new(Test::Location.new(uri, tag[:location][:line]), tag[:name]) }
        Test::Case.new(pickle[:name], test_steps, Test::Location.new(uri, lines), tags, pickle[:language])
      end

      def create_test_step(pickle_step, uri)
        lines = pickle_step[:locations].map { |location| location[:line] }.sort.reverse
        multiline_arg = create_multiline_arg(pickle_step, uri)
        Test::Step.new(pickle_step[:text], Test::Location.new(uri, lines), multiline_arg)
      end

      def create_multiline_arg(pickle_step, uri)
        if !pickle_step[:doc_string].nil?
          argument = pickle_step[:doc_string]
          Test::DocString.new(
            argument[:content],
            argument[:content_type],
            Test::Location.new(uri, argument[:location][:line])
          )
        elsif !pickle_step[:data_table].nil?
          argument = pickle_step[:data_table]
          first_cell = argument[:rows].first[:cells].first
          Test::DataTable.new(
            argument[:rows].map { |row| row[:cells].map { |cell| cell[:value] } },
            Test::Location.new(uri, first_cell[:location][:line])
          )
        else
          Test::EmptyMultilineArgument.new
        end
      end
    end
  end
end
