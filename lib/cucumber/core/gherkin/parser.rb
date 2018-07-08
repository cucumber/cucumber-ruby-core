# frozen_string_literal: true
require 'gherkin/parser'
require 'gherkin/token_scanner'
require 'gherkin/errors'
require 'cucumber/core/gherkin/ast_builder'
require 'cucumber/core/ast'

module Cucumber
  module Core
    module Gherkin
      ParseError = Class.new(StandardError)

      class Parser
        attr_reader :receiver, :event_bus
        private     :receiver, :event_bus

        def initialize(receiver, event_bus)
          @receiver = receiver
          @event_bus = event_bus
        end

        def document(document)
          parser        = ::Gherkin::Parser.new
          scanner       = ::Gherkin::TokenScanner.new(document.body)
          token_matcher = ::Gherkin::TokenMatcher.new(document.language)
          core_builder  = AstBuilder.new(document.uri)

          begin
            result = parser.parse(scanner, token_matcher)
            event_bus.gherkin_source_parsed(document.uri, result.dup)

            receiver.feature core_builder.feature(result)
          rescue *PARSER_ERRORS => e
            raise Core::Gherkin::ParseError.new("#{document.uri}: #{e.message}")
          end
        end

        def done
          receiver.done
          self
        end

        private

        PARSER_ERRORS = ::Gherkin::ParserError

      end
    end
  end
end
