require 'cucumber/core/test/timer'
require 'cucumber/core/test/duration_matcher'

module Cucumber
  module Core
    module Test
      describe Timer do
        before do
          time = double
          allow( Time ).to receive(:now) { time }
          allow( time ).to receive(:nsec).and_return(946752000, 946752001)
          allow( time ).to receive(:to_i).and_return(1377009235, 1377009235)
        end

        it "returns a Result::Duration object" do
          timer = Timer.new.start
          expect( timer.duration ).to be_duration 1
        end

        it "would be slow to test" do
          # so we won't
        end
      end
    end
  end
end
