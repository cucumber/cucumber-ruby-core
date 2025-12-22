# frozen_string_literal: true

require_relative '../document'
require_relative 'feature'

module Cucumber
  module Core
    module Gherkin
      module Writer
        class Gherkin
          def initialize(uri, &source)
            @uri = uri
            @source = source
          end

          def comment(line)
            comment_lines << "# #{line}"
          end

          def comment_lines
            @comment_lines ||= []
          end

          def feature(*args, &source)
            @feature = Feature.new(comment_lines, *args).tap do |builder|
              builder.instance_exec(&source) if source
            end
            self
          end

          def build
            instance_exec(&@source)
            Document.new(@uri, @feature.build.join("\n"))
          end
        end
      end
    end
  end
end
