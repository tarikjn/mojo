class TimeRange
  attr_reader :start, :end
  
  # make class method
  def parse_time(s)
    e = s.split(/:/)
    e[0].to_i.hours + e[1].to_i.minutes
  end
  
  # # will receive 1s, 2s, 3s from Controller
  def initialize(day, time_start_or_range, time_end = nil)
    if (time_end.nil?) # receiving combined time range
      time_start_or_range, time_end = time_start_or_range.split(/-/)
    end
    
    date = Date.parse(day)
    @start = date + self.parse_time(time_start_or_range)
    @end = date + self.parse_time(time_end)
  end

end
