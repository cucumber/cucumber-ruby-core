# -*- encoding: utf-8 -*-
require 'cucumber/core/test/result'

module Cucumber::Core::Test
  describe Result do

    describe Result::Passed do
      subject(:result) { Result::Passed.new }

      it "describes itself to a visitor" do
        visitor = double
        args = double
        visitor.should_receive(:passed).with(args)
        result.describe_to(visitor, args)
      end

      it "converts to a string" do
        result.to_s.should == "✓"
      end

      it { should     be_passed    }
      it { should_not be_failed    }
      it { should_not be_undefined }
      it { should_not be_unknown   }
      it { should_not be_skipped   }
    end

    describe Result::Failed do
      subject(:result) { Result::Failed.new(exception) }
      let(:exception)  { StandardError.new("error message") }

      it "describes itself to a visitor" do
        visitor = double
        args = double
        visitor.should_receive(:failed).with(args)
        visitor.should_receive(:exception).with(exception, args)
        result.describe_to(visitor, args)
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
        args = double
        result.describe_to(visitor, args)
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
        visitor = double
        args = double
        visitor.should_receive(:undefined).with(args)
        result.describe_to(visitor, args)
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
        visitor = double
        args = double
        visitor.should_receive(:skipped).with(args)
        result.describe_to(visitor, args)
      end

      it { should_not be_passed    }
      it { should_not be_failed    }
      it { should_not be_undefined }
      it { should_not be_unknown   }
      it { should     be_skipped   }
    end
  end
end
