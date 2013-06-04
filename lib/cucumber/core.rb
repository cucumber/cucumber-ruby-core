require 'cucumber/core/ast/gherkin_builder.rb'
require 'cucumber/core/test_suite.rb'
require 'gherkin/parser/parser'

module Cucumber
  module Core
    def parse_gherkin(source, path='unknown')
      builder = Ast::GherkinBuilder.new(path)
      parser = Gherkin::Parser::Parser.new(builder, true, "root", false)

      begin
        parser.parse(source, path, 0)
        builder.language = parser.i18n_language
        builder.result
      rescue Gherkin::Lexer::LexingError, Gherkin::Parser::ParseError => e
        e.message.insert(0, "#{path}: ")
        raise e
      end
    end

    def compile(features)
      TestSuite.new([])
    end
  end
end
