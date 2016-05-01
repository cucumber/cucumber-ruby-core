module Cucumber
  module Core
    class Event
      def self.new(*attributes)
        # Use normal constructor for subclasses of Event
        return super if self.ancestors.index(Event) > 0

        Class.new(Event) do
          attr_reader(*attributes)

          define_method(:initialize) do |*args|
            attributes.zip(args) do |name, value|
              instance_variable_set "@#{name}".to_sym, value
            end
          end

          define_method(:attributes) do
            attributes.map { |attribute| self.send(attribute) }
          end

          define_method(:to_h) do
            attributes.reduce({}) { |result, attribute| 
              value = self.send(attribute)
              result[attribute] = value
              result
            }
          end
        end
      end
    end
  end
end
