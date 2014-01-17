module Cucumber
  module Core
    module Test
      class TagFilter
        include Cucumber.initializer(:filter_expressions, :receiver)

        def test_case(test_case)
          tag_counter.count(test_case)
          if test_case.match_tags?(filter_expressions)
            test_case.describe_to(receiver)
          end
          self
        end

        def done
          tag_limits.enforce(tag_counter)
          @receiver.done
          self
        end

        private
        def tag_counter
          @tag_counter ||= TagCounter.new
        end

        def tag_limits
          @tag_limits ||= TagLimits.new(filter_expressions)
        end

        class TagCounter
          attr_reader :tag_name_locations, :tag_name_counts
          private :tag_name_locations, :tag_name_counts
          def initialize
            @tag_name_locations = Hash.new { [] }
            @tag_name_counts = Hash.new { 0 }
          end

          def count(test_case)
            test_case.tags.each do |tag|
              tag_name_locations[tag.name] += [test_case.location]
              tag_name_counts[tag.name] += 1
            end
            self
          end

          def count_for(tag_name)
            tag_name_counts[tag_name]
          end

          def locations_for(tag_name)
            tag_name_locations[tag_name]
          end
        end

        class TagLimits
          attr_reader :limit_list
          private :limit_list
          def initialize(filter_expressions)
            @limit_list = Hash[
              Array(filter_expressions).map{ |filter_expression|
                if matchdata = filter_expression.match(/^(?:~)?(\@[\w\d]+)\:(\d+)$/)
                  [matchdata[1], Integer(matchdata[2])]
                end
              }.compact
            ]
          end

          def enforce(tag_counter)
            limit_breaches = limit_list.reduce([]) do |breaches, (tag_name, limit)|
              tag_count = tag_counter.count_for(tag_name)
              if tag_count > limit
                tag_locations = tag_counter.locations_for(tag_name)
                breaches << TagLimitBreach.new(
                  tag_count,
                  limit,
                  tag_name,
                  tag_locations
                )
              end
              breaches
            end
            raise TagExcess.new(limit_breaches) if !limit_breaches.empty?
            self
          end
        end

        TagLimitBreach = Struct.new(
          :tag_count,
          :tag_limit,
          :tag_name,
          :tag_locations
        ) do

          def message
            "#{tag_name} occurred #{tag_count} times, but the limit was set to #{tag_limit}\n  " + tag_locations.map(&:to_s).join("\n  ")
          end
          alias :to_s :message
        end

        class TagExcess < StandardError
          def initialize(limit_breaches)
            super(limit_breaches.map(&:to_s).join("\n"))
          end
        end
      end
    end
  end
end
