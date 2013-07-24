# -*- encoding: utf-8 -*-
require 'cucumber/core/test/result'

module Cucumber::Core::Test
  describe Result do

    let(:visitor) { double('visitor') }
    let(:args)    { double('args')    }

    describe Result::Passed do
      subject(:result) { Result::Passed.new(duration) }
      let(:duration)   { 1 * 1000 * 1000 }

      it "describes itself to a visitor" do
        visitor.should_receive(:passed).with(args)
        visitor.should_receive(:duration).with(duration, args)
        result.describe_to(visitor, args)
      end

      it "converts to a string" do
        result.to_s.should == "✓"
      end

      it "has a duration" do
        result.duration.should == duration
      end

      it { should     be_passed    }
      it { should_not be_failed    }
      it { should_not be_undefined }
      it { should_not be_unknown   }
      it { should_not be_skipped   }
    end

    describe Result::Failed do
      subject(:result) { Result::Failed.new(duration, exception) }
      let(:duration)   { 1 * 1000 * 1000 }
      let(:exception)  { StandardError.new("error message") }

      it "describes itself to a visitor" do
        visitor.should_receive(:failed).with(args)
        visitor.should_receive(:duration).with(duration, args)
        visitor.should_receive(:exception).with(exception, args)
        result.describe_to(visitor, args)
      end

      it "has a duration" do
        result.duration.should == duration
      end

      it { should_not be_passed    }
      it { should     be_failed    }
      it { should_not be_undefined }
      it { should_not be_unknown   }
      it { should_not be_skipped   }
    end

    describe Result::Unknown do
      subject(:result) { Result::Unknown.new }

      it "doesn't describe itself to a visitor" do
        visitor = double('never receives anything')
        result.describe_to(visitor, args)
      end

      it "has no duration" do
        expect { result.duration }.to raise_error NoMethodError
      end

      it { should_not be_passed    }
      it { should_not be_failed    }
      it { should_not be_undefined }
      it { should     be_unknown   }
      it { should_not be_skipped   }
    end

    describe Result::Undefined do
      subject(:result) { Result::Undefined.new }

      it "describes itself to a visitor" do
        visitor.should_receive(:undefined).with(args)
        result.describe_to(visitor, args)
      end

      it "has no duration" do
        expect { result.duration }.to raise_error NoMethodError
      end

      it { should_not be_passed    }
      it { should_not be_failed    }
      it { should     be_undefined }
      it { should_not be_unknown   }
      it { should_not be_skipped   }
    end

    describe Result::Skipped do
      subject(:result) { Result::Skipped.new }

      it "describes itself to a visitor" do
        visitor.should_receive(:skipped).with(args)
        result.describe_to(visitor, args)
      end

      it "has no duration" do
        expect { result.duration }.to raise_error NoMethodError
      end

      it { should_not be_passed    }
      it { should_not be_failed    }
      it { should_not be_undefined }
      it { should_not be_unknown   }
      it { should     be_skipped   }
    end

    describe Result::Summary do
      let(:summary)   { Result::Summary.new }
      let(:failed)    { Result::Failed.new(10, exception) }
      let(:passed)    { Result::Passed.new(11) }
      let(:skipped)   { Result::Skipped.new }
      let(:unknown)   { Result::Unknown.new }
      let(:undefined) { Result::Undefined.new }
      let(:exception) { StandardError.new }

      it "counts failed results" do
        failed.describe_to summary
        summary.total_failed.should eq(1)
        summary.total.should eq(1)
      end

      it "counts passed results" do
        passed.describe_to summary
        summary.total_passed.should eq(1)
        summary.total.should eq(1)
      end

      it "counts skipped results" do
        skipped.describe_to summary
        summary.total_skipped.should eq(1)
        summary.total.should eq(1)
      end

      it "counts undefined results" do
        undefined.describe_to summary
        summary.total_undefined.should eq(1)
        summary.total.should eq(1)
      end

      it "doesn't count unknown results" do
        unknown.describe_to summary
        summary.total.should eq(0)
      end

      it "counts combinations" do
        [passed, passed, failed, skipped, undefined].each { |r| r.describe_to summary }
        summary.total.should eq(5)
        summary.total_passed.should eq(2)
        summary.total_failed.should eq(1)
        summary.total_skipped.should eq(1)
        summary.total_undefined.should eq(1)
      end

      it "records durations" do
        [passed, failed].each { |r| r.describe_to summary }
        summary.durations.should == [11, 10]
      end

      it "records exceptions" do
        [passed, failed].each { |r| r.describe_to summary }
        summary.exceptions.should == [exception]
      end
    end
  end
end
