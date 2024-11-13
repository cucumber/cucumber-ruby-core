# frozen_string_literal: true

class ReportAPISpy
  def initialize
    @result = []
  end

  def test_case(*args)
    @result << :test_case
    yield self
  end

  def test_step(*args)
    @result << :test_step
  end

  def done
    @result << :done
  end

  def messages
    @result
  end
end
