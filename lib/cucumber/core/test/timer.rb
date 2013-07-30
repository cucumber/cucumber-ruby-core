class Timer
  def start
    @start_time = time_in_nanoseconds
  end

  def duration
    time_in_nanoseconds - @start_time
  end

  private

  def time_in_nanoseconds
    Time.now.nsec
  end
end
