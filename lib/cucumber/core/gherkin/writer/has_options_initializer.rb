# frozen_string_literal: true

module Cucumber
  module Core
    module Gherkin
      module Writer
        module HasOptionsInitializer
          def self.included(base)
            base.extend HasDefaultKeyword
          end

          attr_reader :name, :options
          private :name, :options

          def initialize(*args)
            @comments = args.shift if args.first.is_a?(Array)
            @comments ||= []
            @options = args.pop if args.last.is_a?(Hash)
            @options ||= {}
            @name = args.first
          end

          private

          def comments_statement
            @comments
          end

          def keyword
            options.fetch(:keyword) { self.class.keyword }
          end

          def name_statement
            "#{keyword}: #{name}".strip
          end

          def tag_statement
            tags
          end

          def tags
            options[:tags]
          end

          module HasDefaultKeyword
            def default_keyword(keyword)
              @keyword = keyword
            end

            def keyword
              @keyword
            end
          end
        end
      end
    end
  end
end
