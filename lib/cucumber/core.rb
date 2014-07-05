require 'cucumber/core/gherkin/parser'
require 'cucumber/core/compiler'
require 'cucumber/core/test/runner'
require 'cucumber/core/test/mapper'
require 'cucumber/core/test/filters/debug_filter'

module Cucumber
  module Core

    def parse(gherkin_documents, compiler)
      parser = Core::Gherkin::Parser.new(compiler)
      gherkin_documents.each do |document|
        parser.document document
      end
      parser.done
      self
    end

    def compile(gherkin_documents, last_receiver, filters = [])
      first_receiver = filters.reverse.reduce(last_receiver) do |receiver, (filter_type, args)|
        filter_type.new(*args + [receiver])
      end
      compiler = Compiler.new(first_receiver)
      parse gherkin_documents, compiler
      self
    end

    def execute(gherkin_documents, mapping_definition, report, filters = [], run_options = {})
      receiver = Test::Runner.new(report)
      filters << [Test::Mapper, [mapping_definition]]
      filters << [Test::DebugFilter, []] if run_options[:debug]
      compile gherkin_documents, receiver, filters
      self
    end

  end
end
