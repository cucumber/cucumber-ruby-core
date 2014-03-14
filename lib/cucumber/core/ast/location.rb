require 'forwardable'
require 'cucumber/core/platform'
module Cucumber
  module Core
    module Ast
      class Location < Struct.new(:filepath, :lines)
        WILDCARD = :*

        extend Forwardable

        def_delegator :lines,    :include?
        def_delegator :lines,    :line
        def_delegator :filepath, :same_as?
        def_delegator :filepath, :filename, :file

        def initialize(filepath, lines=WILDCARD)
          filepath || raise(ArgumentError, "file is mandatory")
          lines || raise(ArgumentError, "line is mandatory")
          super(FilePath.new(filepath), Lines.new(lines))
        end

        def match?(other)
          other.same_as?(filepath) && other.include?(lines)
        end

        def to_s
          [filepath.to_s, lines.to_s].reject { |v| v == WILDCARD.to_s }.join(":")
        end

        def hash
          self.class.hash ^ to_s.hash
        end

        def to_str
          to_s
        end

        def on_line(new_line)
          Location.new(filepath.filename, new_line)
        end

        def inspect
          "<#{self.class}: #{to_s}>"
        end

        class FilePath < Struct.new(:filename)
          def same_as?(other)
            filename == other.filename
          end

          def to_s
            filename
          end
        end

        require 'set'
        class Lines < Struct.new(:data)
          protected :data
          attr_reader :line

          def initialize(line)
            if Cucumber::JRUBY && line.is_a?(::Java::GherkinFormatterModel::Range)
              line = Range.new(line.first, line.last)
            end
            @line = line
            super Array(line).to_set
          end

          def include?(other)
            return true if (data|other.data).include?(WILDCARD)
            other.data.subset?(data) || data.subset?(other.data)
          end

          def to_s
            boundary.join('..')
          end

          def inspect
            "<#{self.class}: #{to_s}>"
          end

          protected

          def boundary
            first_and_last(value).uniq
          end

          def at_index(idx)
            data.to_a[idx]
          end

          def value
            method :at_index
          end

          def first_and_last(something)
            [0, -1].map(&something)
          end
        end
      end

      module HasLocation
        def file_colon_line
          location.to_s
        end

        def file
          location.file
        end

        def line
          location.line
        end

        def location
          raise('Please set @location in the constructor') unless defined?(@location)
          @location
        end

        def match_locations?(queried_locations)
          return true if attributes.any? { |node| node.match_locations? queried_locations }
          queried_locations.any? { |queried_location| queried_location.match? location }
        end

        def attributes
          [tags, comments, multiline_arg].flatten
        end

        def tags
          # will be overriden by nodes that actually have tags
          []
        end

        def comments
          # will be overriden by nodes that actually have comments
          []
        end

        def multiline_arg
          # will be overriden by nodes that actually have a multiline_argument
          EmptyMultilineArgument.new
        end

      end
    end
  end
end
