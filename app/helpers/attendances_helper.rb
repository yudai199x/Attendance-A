module AttendancesHelper
  
  def attendance_state(attendance)
    if Date.current == attendance.worked_on
      return '出社' if attendance.started_at.nil?
      return '退社' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    false
  end
  
  def working_day(date)
    l(date, format: :short)
  end
  
  def working_show(time, str)
    return time.floor_to(15.minutes).strftime(str) if time.present?
  end
  
  def working_times(overnight, start, finish)
    overnight == '1' ? h = 24 : h = 0
    format("%.2f", (((finish.floor_to(15.minutes) - start.floor_to(15.minutes)) / 60) / 60.0) + h)
  end
  
  def working_overtimes(overnight, skd_time, end_time)
    overnight == '1' ? h = 24 : h = 0
    format("%.2f", (((skd_time.hour - end_time.hour) * 60 + (skd_time.min - end_time.min)) / 60.0) + h)
  end
end
