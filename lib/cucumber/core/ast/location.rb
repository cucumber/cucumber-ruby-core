module Cucumber
  module Core
    module Ast

      class Location < Struct.new(:file, :line)
        def initialize(file, line)
          file || raise(ArgumentError, "file is mandatory")
          line || raise(ArgumentError, "line is mandatory")
          super
        end

        def to_s
          "#{file}:#{line}"
        end

        def on_line(new_line)
          Location.new(file, new_line)
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
          raise('Please set @location in the constructor') unless @location
          raise("@location must be an Ast::Location but is a #{@location.class}") unless @location.is_a?(Location)
          @location
        end
      end
    end
  end
end
