# frozen_string_literal: true
require 'cucumber/core/ast/describes_itself'
require 'cucumber/core/ast/location'

module Cucumber
  module Core
    module Ast
      class Step
        include HasLocation
        include DescribesItself

        attr_reader :keyword, :text, :language, :comments, :exception, :multiline_arg

        def initialize(language, location, comments, keyword, text, multiline_arg)
          @language, @location, @comments, @keyword, @text, @multiline_arg = language, location, comments, keyword, text, multiline_arg
        end

        def to_s
          text
        end

        def backtrace_line
          "#{location}:in `#{keyword}#{text}'"
        end

        def actual_keyword(previous_step_keyword = nil)
          if [language.and_keywords, language.but_keywords].flatten.uniq.include? keyword
            if previous_step_keyword.nil?
              language.given_keywords.reject{|kw| kw == '* '}[0]
            else
              previous_step_keyword
            end
          else
            keyword
          end
        end

        def original_location
          location
        end

        def inspect
          keyword_and_text = [keyword, text].join(": ")
          %{#<#{self.class} "#{keyword_and_text}" (#{location})>}
        end


        private

        def children
          [@multiline_arg]
        end

        def description_for_visitors
          :step
        end
      end

      class ExpandedOutlineStep < Step

        def initialize(outline_step, language, location, comments, keyword, text, multiline_arg)
          @outline_step, @language, @location, @comments, @keyword, @text, @multiline_arg = outline_step, language, location, comments, keyword, text, multiline_arg
        end

        def all_locations
          @outline_step.all_locations
        end

        def original_location
          @outline_step.location
        end

        alias :step_backtrace_line :backtrace_line

        def backtrace_line
          "#{step_backtrace_line}\n" +
          "#{@outline_step.location}:in `#{@outline_step.keyword}#{@outline_step.text}'"
        end

      end
    end
  end
end
