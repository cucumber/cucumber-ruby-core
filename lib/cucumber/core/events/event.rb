module Cucumber
  module Core
    module Event
      def self.new(*attributes)
        Class.new do
          attr_reader(*attributes)

          define_method(:initialize) do |*args|
            attributes.zip(args) do |name, value|
              instance_variable_set "@#{name}".to_sym, value
            end
          end

          define_method(:attributes) do
            attributes.map { |attribute| self.send(attribute) }
          end

        end
      end
    end
  end
end
