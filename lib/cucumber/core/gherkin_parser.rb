require 'cucumber/core/ast/gherkin_builder'
require 'gherkin/parser/parser'

module Cucumber
  module Core
    module Gherkin
      ParseError = Class.new(StandardError)
    end

    class GherkinParser
      include Cucumber.initializer(:source, :path)

      def feature
        builder = Ast::GherkinBuilder.new(path)
        parser = ::Gherkin::Parser::Parser.new(builder, true, "root", false)

        begin
          parser.parse(source, path, 0)
          builder.language = parser.i18n_language
          builder.result
        rescue ::Gherkin::Lexer::LexingError, ::Gherkin::Parser::ParseError, Java::GherkinLexer::LexingError => e
          raise Core::Gherkin::ParseError.new("#{path}: #{e.message}")
        end
      end
    end
  end
end
