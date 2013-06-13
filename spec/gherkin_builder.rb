module GherkinBuilder
  def gherkin(&source)
    builder = Gherkin.new
    builder.instance_exec(&source)
    builder.build
  end

  class Gherkin

    def feature(name=nil, &source)
      @feature = Feature.new(name)
      @feature.instance_exec(&source)
      self
    end

    def build
      @feature.build
    end

    class Feature
      attr_reader :name
      private :name
      def initialize(name)
        @name = name
      end

      def background(name=nil, &source)
        Background.new(name).tap do |builder|
          builder.instance_exec(&source) if source
          elements << builder
        end
        self
      end

      def scenario(name=nil, &source)
        Scenario.new(name).tap do |builder|
          builder.instance_exec(&source) if source
          elements << builder
        end
        self
      end

      def build
        elements.inject(["Feature: #{name}"]) { |acc, el| el.build(acc) }.join("\n")
      end

      def elements
        @elements ||= []
      end

      class Background
        attr_reader :name
        private :name
        def initialize(name)
          @name = name
        end

        def step(name)
          elements << Step.new(name)
          self
        end

        def build(source)
          source << "  Background: #{name}"
          elements.inject(source) { |acc, el| el.build(acc) }
        end

        private
        def elements
          @elements ||= []
        end
      end

      class Scenario
        attr_reader :name
        private :name
        def initialize(name)
          @name = name
        end

        def step(name)
          elements << Step.new(name)
          self
        end

        def build(source)
          source << "  Scenario: #{name}"
          elements.inject(source) { |acc, el| el.build(acc) }
        end

        private
        def elements
          @elements ||= []
        end
      end

      class Step
        attr_reader :name
        private :name
        def initialize(name)
          @name = name
        end

        def build(source)
          source + ["    Given #{name}"]
        end
      end
    end
  end
end
