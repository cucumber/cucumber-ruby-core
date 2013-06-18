module Cucumber
  module Core
    module Ast
      # Represents an inline argument in a step. Example:
      #
      #   Given the message
      #     """
      #     I like
      #     Cucumber sandwich
      #     """
      #
      # The text between the pair of <tt>"""</tt> is stored inside a DocString,
      # which is yielded to the StepDefinition block as the last argument.
      #
      # The StepDefinition can then access the String via the #to_s method. In the
      # example above, that would return: <tt>"I like\nCucumber sandwich"</tt>
      #
      # Note how the indentation from the source is stripped away.
      #
      class DocString < String #:nodoc:
        include DescribesItself
        attr_accessor :file

        def self.default_arg_name
          "string"
        end

        attr_reader :content_type

        def initialize(string, content_type)
          @content_type = content_type
          super string
        end

        def to_step_definition_arg
          self
        end

        def arguments_replaced(arguments) #:nodoc:
          string = self
          arguments.each do |name, value|
            value ||= ''
            string = string.gsub(name, value)
          end
          DocString.new(string, content_type)
        end

        def has_text?(text)
          index(text)
        end
        private

        def description_for_visitors
          :doc_string
        end

      end
    end
  end
end
