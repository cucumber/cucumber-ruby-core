module Cucumber
  module Core
    module Result
      Unknown = Struct.new(:subject) do
        include DescribesItself

        def description_for_visitors
          :unknown
        end
      end

      Passed = Struct.new(:subject) do
        include DescribesItself

        def description_for_visitors
          :passed
        end
      end

      Failed = Struct.new(:subject) do
        include DescribesItself

        def description_for_visitors
          :failed
        end
      end
    end
  end
end
