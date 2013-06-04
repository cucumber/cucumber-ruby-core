module Cucumber
  module Core
    module Ast
      module Names
        attr_reader :title, :description

        def name
          s = @title
          s += "\n#{@description}" if @description != ""
          s
        end

        def to_s
          @title
        end
      end
    end
  end
end
