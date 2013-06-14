module GherkinBuilder
  NEW_LINE = ''
  def gherkin(&source)
    builder = Gherkin.new(&source)
    builder.build
  end

  module HasOptionsInitializer
    def self.included(base)
      base.extend HasDefaultKeyword
    end

    attr_reader :name, :options
    private :name, :options

    def initialize(*args)
      @options = args.pop if args.last.is_a?(Hash)
      @options ||= {}
      @name = args.first
    end

    private
    def keyword
      options.fetch(:keyword) { self.class.keyword }
    end

    def name_statement
      "#{keyword}: #{name}".strip
    end

    def tag_statement
      tags
    end

    def tags
      options[:tags]
    end

    module HasDefaultKeyword
      def default_keyword(keyword)
        @keyword = keyword
      end

      def keyword
        @keyword
      end
    end
  end

  module HasElements
    def self.included(base)
      base.extend HasElementBuilders
    end

    def build(source = [])
      elements.inject(source + statements) { |acc, el| el.build(acc) }
    end

    private
    def elements
      @elements ||= []
    end

    module HasElementBuilders
      def elements(*names)
        names.each { |name| element(name) }
      end

      private
      def element(name)
        define_method name do |*args, &source|
          factory_name = String(name).split("_").map(&:capitalize).join
          factory = GherkinBuilder.const_get(factory_name)
          factory.new(*args).tap do |builder|
            builder.instance_exec(&source) if source
            elements << builder
          end
          self
        end
      end
    end
  end

  module Indentation
    def self.level(number)
      Module.new do
        define_method :indent do |string, modifier=0|
          return string if string.nil? || string.empty?
          (' ' * (number + modifier)) + string
        end
      end
    end
  end

  module HasRows
    def row(*cells)
      rows << cells
    end

    def rows
      @rows ||= []
    end

    private
    def row_statements(indent_modifier=0)
      rows.map { |row| indent(table_row(row), indent_modifier) }
    end

    def table_row(row)
      padded = pad(row)
      "| #{padded.join(' | ')} |"
    end

    def pad(row)
      row.map.with_index { |text, position| justify_cell(text, position) }
    end

    def column_length(column)
      lengths = rows.transpose.map { |r| r.map(&:length).max }
      lengths[column]
    end

    def justify_cell(cell, position)
      cell.ljust(column_length(position))
    end
  end

  class Gherkin
    def initialize(&source)
      @source = source
    end

    def feature(*args, &source)
      @feature = Feature.new(*args).tap do |builder|
        builder.instance_exec(&source) if source
      end
      self
    end

    def build
      instance_exec &@source
      @feature.build.join("\n")
    end
  end

  class Feature
    include HasElements
    include HasOptionsInitializer

    default_keyword 'Feature'

    elements :background, :scenario, :scenario_outline

    def build(source = [])
      elements.inject(source + statements) { |acc, el| el.build(acc) + [NEW_LINE] }
    end

    private
    def language
      options[:language]
    end

    def statements
      strings = [
        language_statement,
        tag_statement,
        name_statement,
        NEW_LINE
      ].compact
    end

    def language_statement
      "# language: #{language}" if language
    end
  end

  class Background
    include HasElements
    include HasOptionsInitializer
    include Indentation.level 2

    default_keyword 'Background'

    elements :step

    private
    def statements
      [
        tag_statement,
        name_statement
      ].compact.map { |s| indent(s) }
    end
  end

  class Scenario
    include HasElements
    include HasOptionsInitializer
    include Indentation.level 2

    default_keyword 'Scenario'

    elements :step

    private
    def statements
      [
        tag_statement,
        name_statement
      ].compact.map { |s| indent(s) }
    end
  end

  class ScenarioOutline
    include HasElements
    include HasOptionsInitializer
    include Indentation.level 2

    default_keyword 'Scenario Outline'

    elements :step, :examples

    private
    def statements
      [
        tag_statement,
        name_statement
      ].compact.map { |s| indent(s) }
    end
  end

  class Step
    include HasElements
    include HasOptionsInitializer
    include Indentation.level 4

    default_keyword 'Given'

    elements :table

    def doc_string(string)
      elements << DocString.new(string)
    end

    private
    def statements
      [ name_statement ].map { |s| indent(s) }
    end

    def name_statement
      "#{keyword} #{name}"
    end
  end

  class Table
    include Indentation.level(6)
    include HasRows

    def build(source)
      source + statements
    end

    private
    def statements
      row_statements
    end
  end

  class DocString
    include Indentation.level(6)

    attr_reader :strings
    private :strings

    def initialize(string)
      @strings = string.split("\n").map(&:strip)
    end

    def build(source)
      source + statements
    end

    private
    def statements
      [
        doc_string_statement
      ].flatten.map { |s| indent(s) }
    end

    def doc_string_statement
      [
        '"""',
        strings,
        '"""'
      ]
    end
  end

  class Examples
    include HasOptionsInitializer
    include HasRows
    include Indentation.level(4)

    default_keyword 'Examples'

    def build(source)
      source + statements
    end

    private
    def rows
      @rows ||= []
    end

    def statements
      [
        NEW_LINE,
        tag_statement,
        name_statement
      ].compact.map { |s| indent(s) } + row_statements(2)
    end
  end
end
