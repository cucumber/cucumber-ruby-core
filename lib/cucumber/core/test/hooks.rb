require 'cucumber/initializer'

module Cucumber
  module Core
    module Test
      module Hooks

        class BeforeHook
          include Cucumber.initializer(:location)
          public :location

          def name
            "Before hook"
          end

          def match_locations?(queried_locations)
            queried_locations.any? { |other_location| other_location.match?(location) }
          end

          def describe_to(visitor, *args)
            visitor.before_hook(self, *args)
          end
        end

        class AfterHook
          include Cucumber.initializer(:location)
          public :location

          def name
            "After hook"
          end

          def match_locations?(queried_locations)
            queried_locations.any? { |other_location| other_location.match?(location) }
          end

          def describe_to(visitor, *args)
            visitor.after_hook(self, *args)
          end
        end

        class AroundHook
          def initialize(&block)
            @block = block
          end

          def describe_to(visitor, *args, &continue)
            visitor.around_hook(self, *args, &continue)
          end

          def call(continue)
            @block.call(continue)
          end
        end

        class AfterStepHook
          include Cucumber.initializer(:location)
          public :location

          def name
            "AfterStep hook"
          end

          def match_locations?(queried_locations)
            queried_locations.any? { |other_location| other_location.match?(location) }
          end

          def describe_to(visitor, *args)
            visitor.after_step_hook(self, *args)
          end
        end

      end
    end
  end
end
