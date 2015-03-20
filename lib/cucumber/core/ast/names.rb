module Cucumber
  module Core
    module Ast
      module Names
        attr_reader :description

        def name
          title
        end

        def title
          warn("deprecated. Use #name")
          @title
        end

        def legacy_conflated_name_and_description
          s = @title
          s += "\n#{@description}" if @description != ""
          s
        end

        def to_s
          @title
        end

        def inspect
          keyword_and_name = [keyword, name].join(": ")
          %{#<#{self.class} "#{keyword_and_name}" (#{location})>}
        end
      end
    end
  end
end
