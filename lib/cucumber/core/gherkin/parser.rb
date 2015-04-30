require 'gherkin/parser'
require 'gherkin/token_scanner'
require 'gherkin/token_matcher'
require 'gherkin/ast_builder'
require 'gherkin/errors'
require 'cucumber/core/gherkin/ast_builder'

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
          parser  = ::Gherkin::Parser.new
          scanner = ::Gherkin::TokenScanner.new(document.body)
          builder = AstTransformer.new

          begin
            result = parser.parse(scanner, builder, ::Gherkin::TokenMatcher.new)

            #builder.language = parser.i18n_language
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

        PARSER_ERRORS = if Cucumber::JRUBY
                          [
                            # Not sure...
                          ]
                        else
                          [
                            ::Gherkin::ParserError,
                          ]
                        end

        class AstTransformer < ::Gherkin::AstBuilder
          def create_ast_value(data)
            data = super

            if data[:type] == :Step && current_node.rule_type == :ScenarioOutline
              data[:type] = :OutlineStep
            end

            ast_class = Ast.const_get(data[:type])
            ast_class.new(attributes_from(data))
          rescue => e
            raise e.class, "Unable to create AST node: '#{data[:type]} from #{data}' #{e.message}", e.backtrace
          end

          def attributes_from(data)
            result = data.dup
            result.delete(:type)
            if result.key?(:rows)
              result[:rows] = result[:rows].map { |r| r[:cells].map { |c| c[:value] } }
            end

            if result.key?(:tableHeader)
              header_attrs = result.delete(:tableHeader)
              header_attrs.delete(:type)
              header_attrs[:cells] = header_attrs[:cells].map { |c| c[:value] }
              result[:header] = Ast::ExamplesTable::Header.new(header_attrs)
            end

            if result.key?(:tableBody)
              body_attrs = result.delete(:tableBody)
              result[:example_rows] = body_attrs.each.with_index.map do |row,index|
                cells = row[:cells].map { |c| c[:value] }
                header = result[:header]
                header.build_row(cells, index + 1, row[:location], row[:language])
              end
            end
            rubify_keys(result)
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
