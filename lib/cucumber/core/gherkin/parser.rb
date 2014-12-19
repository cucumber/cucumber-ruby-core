require 'cucumber/core/gherkin/ast_builder'
require 'gherkin/parser/parser'

module Cucumber
  module Core
    module Gherkin
      ParseError = Class.new(StandardError)

      class Parser
        attr_reader :receiver
        private     :receiver

        def initialize(receiver)
          @receiver = receiver
        end

        def document(document)
          builder = AstBuilder.new(document.uri)
          parser = ::Gherkin::Parser::Parser.new(builder, true, "root", false)

          begin
            parser.parse(document.body, document.uri, 0)
            builder.language = parser.i18n_language
            receiver.feature builder.result
          rescue *PARSER_ERRORS => e
            raise Core::Gherkin::ParseError.new("#{document.uri}: #{e.message}")
          end
        end

        def done
          receiver.done
          self
        end

        private

        PARSER_ERRORS = if Cucumber::JRUBY
                          [
                            ::Java::GherkinLexer::LexingError
                          ]
                        else
                          [
                            ::Gherkin::Lexer::LexingError,
                            ::Gherkin::Parser::ParseError,
                          ]
                        end
      end
    end
  end
end
