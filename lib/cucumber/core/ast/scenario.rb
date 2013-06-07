require 'cucumber/initializer'
require 'cucumber/core/describes_itself'
require 'cucumber/ast/names'
require 'cucumber/ast/empty_background'
require 'cucumber/ast/location'

module Cucumber
  module Core
    module Ast
      class Scenario #:nodoc:
        include Names
        include HasLocation
        include DescribesItself

        attr_reader   :feature_tags
        attr_accessor :feature
        attr_reader   :comment, :tags, :keyword, :background

        include Cucumber.initializer(:language, :location, :background, :comment, :tags, :feature_tags, :keyword, :title, :description, :raw_steps)

        def initialize(*)
          super
          @exception = @executed = nil
        end

        def gherkin_statement(node)
          @gherkin_statement = node
        end

        def children
          raw_steps
        end

        def accept(visitor)
          background.accept(visitor)
          visitor.visit_feature_element(self) do
            comment.accept(visitor)
            tags.accept(visitor)
            visitor.visit_scenario_name(keyword, name, file_colon_line, source_indent(first_line_length))
            skip_invoke! if background.failed?
            with_visitor(visitor) do
              execute(visitor.runtime, visitor)
            end
            @executed = true
          end
        end

        def execute(runtime, visitor)
          runtime.with_hooks(self, skip_hooks?) do
            step_invocations.accept(visitor)
          end
        end

        # Returns true if one or more steps failed
        def failed?
          step_invocations.failed? || !!@exception
        end

        def fail!(exception)
          @exception = exception
          @current_visitor.visit_exception(@exception, :failed)
          skip_invoke!
        end

        # Returns true if all steps passed
        def passed?
          !failed?
        end

        # Returns the first exception (if any)
        def exception
          @exception || step_invocations.exception
        end

        # Returns the status
        def status
          return :failed if @exception
          step_invocations.status
        end

        def to_sexp
          sexp = [:scenario, line, keyword, name]
          comment = comment.to_sexp
          sexp += [comment] if comment
          tags = tags.to_sexp
          sexp += tags if tags.any?
          sexp += step_invocations.to_sexp if step_invocations.any?
          sexp
        end

        def with_visitor(visitor)
          @current_visitor = visitor
          yield
          @current_visitor = nil
        end

        def skip_invoke!
          step_invocations.skip_invoke!
        end

        def step_invocations
          @step_invocation ||= background.create_step_invocations(my_step_invocations)
        end

        def executable_steps
          step_invocations
        end

        def all_steps
          background.raw_steps + raw_steps
        end

        private

        def steps
          StepCollection.new(raw_steps)
        end

        def my_step_invocations
          raw_steps.map { |step| step.step_invocation }
        end

        def skip_hooks?
          background.failed? || @executed
        end

        def description_for_visitors
          :scenario
        end

      end
    end
  end
end
