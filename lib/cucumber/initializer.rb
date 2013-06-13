module Cucumber
  def self.initializer(*attributes)
    Module.new do
      attr_reader(*attributes)
      private(*attributes)

      define_method(:initialize) do |*arguments|
        if attributes.size != arguments.size
          raise ArgumentError, "wrong number of arguments (#{arguments.size} for #{attributes.size})"
        end

        attributes.zip(arguments) do |attribute, argument|
          instance_variable_set("@#{attribute}", argument)
        end
      end
    end
  end
end
