module Cucumber
  module Core
    module Test
      class Timer
        def start
          @start_time = time_in_nanoseconds
          self
        end

        def duration
          nsec
        end

        def nsec
          time_in_nanoseconds - @start_time
        end

        def sec
          nsec / 10 ** 9.0
        end

        private

        def time_in_nanoseconds
          t = Time.now
          t.to_i * 10 ** 9 + t.nsec
        end
      end
    end
  end
end
