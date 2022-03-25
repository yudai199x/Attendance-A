module AttendancesHelper
  
  def attendance_state(attendance)
    if Date.current == attendance.worked_on
      return '出社' if attendance.started_at.nil?
      return '退社' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    false
  end
  
  def working_show(time, str)
    return time.floor_to(15.minutes).strftime(str) if time.present?
  end
  
  def working_times(start, finish)
    format("%.2f", (((finish.floor_to(15.minutes) - start.floor_to(15.minutes)) / 60) / 60.0))
  end
end
