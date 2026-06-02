# frozen_string_literal: true

module Cucumber
  module Core
    module Gherkin
      module Writer
        module HasElements
          include AcceptsComments

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
              define_method(name) do |*args, &source|
                factory_name = String(name).split('_').map(&:capitalize).join
                factory = Writer.const_get(factory_name)
                factory.new(slurp_comments, *args).tap do |builder|
                  builder.instance_exec(&source) if source
                  elements << builder
                end
                self
              end
            end
          end
        end
      end
    end
  end
end
