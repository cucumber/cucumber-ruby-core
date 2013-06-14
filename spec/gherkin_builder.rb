module GherkinBuilder
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
    def build(source = [])
      elements.inject(source + statements) { |acc, el| el.build(acc) }
    end

    private
    def elements
      @elements ||= []
    end
  end

  module Indentation
    def self.level(number)
      Module.new do
        define_method :indent do |string, modifier=0|
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
    def pad(row)
      row.map.with_index { |cell, index| cell.ljust(column_length(index)) }
    end

    def row_statements(indent_modifier=0)
      rows.map do |row|
        "| #{pad(row).join(' | ')} |"
      end.map { |s| indent(s, indent_modifier) }
    end

    def column_length(column)
      lengths = rows.transpose.map { |r| r.map(&:length).max }
      lengths[column]
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

    def build(source = [])
      elements.inject(source + statements) { |acc, el| el.build(acc) + [''] }
    end

    def background(*args, &source)
      Background.new(*args).tap do |builder|
        builder.instance_exec(&source) if source
        elements << builder
      end
      self
    end

    def scenario(*args, &source)
      Scenario.new(*args).tap do |builder|
        builder.instance_exec(&source) if source
        elements << builder
      end
      self
    end

    def scenario_outline(*args, &source)
      ScenarioOutline.new(*args).tap do |builder|
        builder.instance_exec(&source) if source
        elements << builder
      end
      self
    end

    private
    def language
      options[:language]
    end

    def statements
      strings = [
        language_statement,
        name_statement,
        ''
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

    def step(*args, &source)
      Step.new(*args).tap do |builder|
        builder.instance_exec(&source) if source
        elements << builder
      end
      self
    end

    private
    def statements
      [ name_statement ].map { |s| indent(s) }
    end
  end

  class Scenario
    include HasElements
    include HasOptionsInitializer
    include Indentation.level 2

    default_keyword 'Scenario'

    def step(*args, &source)
      Step.new(*args).tap do |builder|
        builder.instance_exec(&source) if source
        elements << builder
      end
      self
    end

    private
    def statements
      [ name_statement ].map { |s| indent(s) }
    end
  end

  class ScenarioOutline
    include HasElements
    include HasOptionsInitializer
    include Indentation.level 2

    default_keyword 'Scenario Outline'

    def step(*args, &source)
      Step.new(*args).tap do |builder|
        builder.instance_exec(&source) if source
        elements << builder
      end
      self
    end

    def examples(*args, &source)
      Examples.new(*args).tap do |builder|
        builder.instance_exec(&source) if source
        elements << builder
      end
      self
    end

    private
    def statements
      [ name_statement ].map { |s| indent(s) }
    end
  end

  class Step
    include HasElements
    include HasOptionsInitializer
    include Indentation.level 4

    default_keyword 'Given'

    def doc_string(string)
      elements << DocString.new(string)
    end

    def table(&source)
      Table.new.tap do |builder|
        builder.instance_exec(&source) if source
        elements << builder
      end
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

    def initialize(string)
      @strings = string.split("\n").map(&:strip)
    end

    def build(source)
      source + statements
    end

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

    attr_reader :strings
    private :strings
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
        '',
        indent(name_statement)
      ] + row_statements(2)
    end
  end
end
