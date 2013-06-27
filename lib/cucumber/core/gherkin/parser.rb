require 'cucumber/core/gherkin/ast_builder'
require 'gherkin/parser/parser'

module Cucumber
  module Core
    module Gherkin
      ParseError = Class.new(StandardError)

      class Parser
        include Cucumber.initializer(:source, :path)

        def feature
          builder = AstBuilder.new(path)
          parser = ::Gherkin::Parser::Parser.new(builder, true, "root", false)

          begin
            parser.parse(source, path, 0)
            builder.language = parser.i18n_language
            builder.result
          rescue *PARSER_ERRORS => e
            raise Core::Gherkin::ParseError.new("#{path}: #{e.message}")
          end
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
