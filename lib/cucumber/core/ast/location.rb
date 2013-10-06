module Cucumber
  module Core
    module Ast

      class Location < Struct.new(:file, :line)
        def initialize(file, line_number=:wildcard)
          file || raise(ArgumentError, "file is mandatory")
          line_number || raise(ArgumentError, "line is mandatory")
          super
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

        def match?(other)
          file == other.file && (
            line == other.line || [line, other.line].include?(:wildcard)
          )
        end

        def inspect
          "<#{self.class}: #{to_s}>"
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
