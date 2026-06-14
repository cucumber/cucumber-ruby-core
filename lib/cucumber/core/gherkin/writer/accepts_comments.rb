# frozen_string_literal: true

module Cucumber
  module Core
    module Gherkin
      module Writer
        module AcceptsComments
          def comment(line)
            comment_lines << "# #{line}"
          end

          def comment_lines
            @comment_lines ||= []
          end

          def slurp_comments
            comment_lines.tap { @comment_lines = nil }
          end
        end
      end
    end
  end
end
