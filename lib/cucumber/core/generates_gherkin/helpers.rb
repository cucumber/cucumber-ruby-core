module Cucumber
  module Core
    module GeneratesGherkin

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
            factory = GeneratesGherkin.const_get(factory_name)
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
            define_method :indent do |string, amount=nil|
            amount ||= number
            return string if string.nil? || string.empty?
            (' ' * amount) + string
            end

            define_method :prepare_statements do |*statements|
              statements.flatten.compact.map { |s| indent(s) }
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

        def row_statements(indent=nil)
          rows.map { |row| indent(table_row(row), indent) }
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
    end
  end
end

