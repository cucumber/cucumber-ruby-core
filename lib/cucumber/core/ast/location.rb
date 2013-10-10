module Cucumber
  module Core
    module Ast
      module Location
        def self.new(file, line_number=:wildcard)
          file || raise(ArgumentError, "file is mandatory")
          line_number || raise(ArgumentError, "line is mandatory")

          case line_number
          when :wildcard
            Wildcard.new(file)
          when Range
            Ranged.new(file, line_number)
          else
            Precise.new(file, line_number)
          end
        end

        def to_s
          [file, line].reject { |v| v == :wildcard }.join(":")
        end

        def to_str
          to_s
        end

        def on_line(new_line)
          Location.new(file, new_line)
        end

        def inspect
          "<#{self.class}: #{to_s}>"
        end

        class Precise < Struct.new(:file, :line)
          include Location

          def match?(other)
            file == other.file && other.match_line?(line)
          end

          def match_line?(queried_line)
            queried_line == line || queried_line == :wildcard
          end
        end

        class Wildcard < Struct.new(:file)
          include Location
          def match?(other)
            file == other.file
          end

          def line
            :wildcard
          end

          def match_line?(queried_line)
            true
          end
        end

        class Ranged < Struct.new(:file, :lines)
          include Location
          def match?(other)
            file == other.file && (
              lines.include?(other.line) || [line, other.line].include?(:wildcard)
            )
          end

          def line
            lines.first
          end

          def match_line?(queried_line)
            lines.include?(queried_line) || queried_line == :wildcard
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
          # TODO: Remove compact when we have a null multiline arg object
          [tags, comments, multiline_arg].flatten.compact
        end

        def tags
          # will be overriden by nodes that actually have tags
          []
        end

        def comments
          []
        end

        def multiline_arg
        end

      end
    end
  end
end
