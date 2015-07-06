require 'gherkin3/parser'
require 'gherkin3/token_scanner'
require 'gherkin3/token_matcher'
require 'gherkin3/ast_builder'
require 'gherkin3/errors'
require 'cucumber/core/gherkin/ast_builder'
require 'cucumber/core/ast'

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
          parser  = ::Gherkin3::Parser.new
          scanner = ::Gherkin3::TokenScanner.new(document.body)
          builder = AstTransformer.new(document.uri)

          if document.body.strip.empty?
            return receiver.feature Ast::NullFeature.new
          end

          begin
            result = parser.parse(scanner, builder, ::Gherkin3::TokenMatcher.new)

            receiver.feature result
          rescue *PARSER_ERRORS => e
            raise Core::Gherkin::ParseError.new("#{document.uri}: #{e.message}")
          end
        end

        def done
          receiver.done
          self
        end

        private

        PARSER_ERRORS = ::Gherkin3::ParserError

        class AstTransformer < ::Gherkin3::AstBuilder
          attr_reader :uri, :ast_builder
          private :uri, :ast_builder

          def initialize(uri)
            super()
            @uri = uri
            @ast_builder = Cucumber::Core::Gherkin::AstBuilder.new(uri)
          end

          def create_ast_value(data)
            data = super

            if data[:type] == :Step && current_node.rule_type == :ScenarioOutline
              data[:type] = :OutlineStep
            end

            attributes = attributes_from(data)
            case data[:type]
            when :Feature
              ast_builder.feature(attributes)
            when :Background
              ast_builder.background(attributes)
            when :Scenario
              ast_builder.scenario(attributes)
            when :ScenarioOutline
              ast_builder.scenario_outline(attributes)
            when :Examples
              ast_builder.examples(attributes)
            when :Step
              ast_builder.step(attributes)
            when :OutlineStep
              ast_builder.outline_step(attributes)
            when :DataTable
              ast_builder.data_table(attributes)
            when :DocString
              ast_builder.doc_string(attributes)
            else
              raise
            end
          rescue => e
            raise e.class, "Unable to create AST node: '#{data[:type]} from #{data}' #{e.message}", e.backtrace
          end

          def attributes_from(data)
            rubify_keys(data.dup)
          end

          def rubify_keys(hash)
            hash.keys.each do |key|
              if key.downcase != key
                hash[underscore(key).to_sym] = hash.delete(key)
              end
            end
            return hash
          end

          def underscore(string)
            string.to_s.gsub(/::/, '/').
              gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
              gsub(/([a-z\d])([A-Z])/,'\1_\2').
              tr("-", "_").
              downcase
          end

        end
      end
    end
  end
end
