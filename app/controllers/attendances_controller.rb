class AttendancesController < ApplicationController
  before_action :set_user, only: [
    :edit_overtime_req, :update_overtime_req, :edit_overtime_aprv, :update_overtime_aprv, :edit_one_month,
    :update_one_month, :edit_chg_aprv, :update_chg_aprv, :update_monthly_req, :edit_monthly_aprv, :update_monthly_aprv
  ]
  before_action :logged_in_user, only: [
    :update, :edit_overtime_req, :update_overtime_req, :edit_overtime_aprv, :update_overtime_aprv, :edit_one_month,
    :update_one_month,:edit_chg_aprv, :update_chg_aprv, :update_monthly_req, :edit_monthly_aprv, :update_monthly_aprv
  ]
  before_action :admin_or_correct_user, only: [
    :update, :edit_overtime_req, :update_overtime_req, :edit_overtime_aprv, :update_overtime_aprv, :edit_one_month,
    :update_one_month,:edit_chg_aprv, :update_chg_aprv, :update_monthly_req, :edit_monthly_aprv, :update_monthly_aprv
  ]
  before_action :superior_user, only: [:edit_overtime_req, :edit_one_month]
  before_action :set_one_month, only: :edit_one_month
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  UPDATE_ONE_MONTH_ERROR_MSG = "勤怠変更申請に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    
    if @attendance.started_at.nil?
      if @attendance.update_attributes(b4_started_at: Time.current, started_at: Time.current)
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(b4_finished_at: Time.current, finished_at: Time.current)
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_overtime_req
    @attendance = @user.attendances.find_by(worked_on: params[:date])
  end
  
  def update_overtime_req
    overtime_req_params.each do |id, item|
      if item["scheduled_at(4i)"].blank? || item["scheduled_at(5i)"].blank? || item[:worked_contents].blank? || item[:confirmed_request].blank? 
        flash[:danger] = "未入力な項目があった為、申請をキャンセルしました。"
      else
        attendance = Attendance.find(id)
        if attendance.started_at.present? && attendance.finished_at.blank?
          if working_show(attendance.started_at, "%H%M").to_i > working_show(attendance.scheduled_at, "%H%M").to_i
            flag = 1 if item[:overwork_next_day] == '1'
          else
            flag = 1
          end
          if flag == 1
            attendance.overwork_chk = '0'
            attendance.overwork_status = "申請中"
            attendance.update_attributes!(item)
            flash[:success] = "残業申請を送信しました。"
          else
            flash[:danger] = "出社時間より早い終了予定時間は無効です。"
          end
        else
          flash[:danger] = "残業申請に失敗しました。やり直してください。"
        end
      end
    end
    redirect_to @user
  end
  
  def edit_overtime_aprv
    @attendances = Attendance.where(confirmed_request: @user.name, overwork_status: "申請中")
    @users = User.where(id: @attendances.select(:user_id))
  end
  
  def update_overtime_aprv
    flag = 0
    overtime_aprv_params.each do |id, item|
      if item[:overwork_chk] == '1'
        unless item[:overwork_status] == "申請中"
          flag += 1
          attendance = Attendance.find(id)
          if item[:overwork_status] == "なし"
            attendance.scheduled_at = nil
            attendance.overwork_next_day = nil
            attendance.worked_contents = nil
            attendance.confirmed_request = nil
          end
          attendance.update_attributes(item)
        end
      end
    end
    if flag > 0
      flash[:success] = "残業申請を更新しました。"
    else
      flash[:danger] = "残業申請の更新に失敗しました。"
    end
    redirect_to user_url(date: params[:date])
  end
  
  def edit_one_month
  end
  
  def update_one_month
    flag = 0
    ActiveRecord::Base.transaction do
      chg_req_params.each do |id, item|
        unless item["started_at(4i)"].blank? || item["started_at(5i)"].blank? || item["finished_at(4i)"].blank? || item["finished_at(5i)"].blank?
          if item[:note].present? && item[:chg_confirmed].present?
            attendance = Attendance.find(id)
            unless attendance.chg_status == "申請中"
              if working_show(attendance.started_at, "%H%M").to_i > working_show(attendance.finished_at, "%H%M").to_i
                flag2 = 1 if item[:chg_next_day] == '1'
              else
                flag2 = 1
              end
              if flag2 == 1
                flag2 = 0
                flag += 1
                if attendance.chg_status == "承認"
                  attendance.chg_chk = '0'
                  attendance.b4_started_at = attendance.af_started_at
                  attendance.b4_finished_at = attendance.af_finished_at
                end
                attendance.chg_status = "申請中"
                attendance.update_attributes!(item)
              end
            end
          end
        end
      end
    end
    if flag > 0
      flash[:success] = "勤怠変更申請を送信しました。"
      redirect_to user_url(date: params[:date])
    else
      flash[:danger] = UPDATE_ONE_MONTH_ERROR_MSG
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = UPDATE_ONE_MONTH_ERROR_MSG
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  def edit_chg_aprv
    @attendances = Attendance.where(chg_confirmed: @user.name, chg_status: "申請中")
    @users = User.where(id: @attendances.select(:user_id))
  end
  
  def update_chg_aprv
    flag = 0
    chg_aprv_params.each do |id, item|
      if item[:chg_chk] == '1'
        unless item[:chg_status] == "申請中"
          flag += 1
          attendance = Attendance.find(id)
          if item[:chg_status] == "承認"
            attendance.aprv_day = Date.current
            attendance.aprv_sup = attendance.chg_confirmed
            attendance.af_started_at = attendance.started_at
            attendance.af_finished_at = attendance.finished_at
          elsif item[:chg_status] == "否認"
            attendance.started_at = attendance.b4_started_at
            attendance.finished_at = attendance.b4_finished_at
          elsif item[:chg_status] == "なし"
            attendance.started_at = nil
            attendance.finished_at = nil
            attendance.chg_next_day = nil
            attendance.note = nil
          end
          attendance.chg_confirmed = nil
          attendance.update_attributes(item)
        end
      end
    end
    if flag > 0
      flash[:success] = "勤怠変更申請を更新しました。"
    else
      flash[:danger] = "勤怠変更申請の更新に失敗しました。"
    end
    redirect_to user_url(date: params[:date])
  end
  
  def update_monthly_req
    flag = 0
    monthly_req_params.each do |id, item|
      if item[:aprv_confirmed].present?
        flag += 1
        attendance = Attendance.find(id)
        attendance.aprv_chk = '0'
        attendance.aprv_status = "申請中"
        attendance.update_attributes(item)
      end
    end
    if flag > 0
      flash[:success] = "1ヶ月分の勤怠申請を送信しました。"
    else
      flash[:danger] = "1ヶ月分の勤怠申請に失敗しました。"
    end
    redirect_to user_url(date: params[:date])    
  end
  
  def edit_monthly_aprv
    @attendances = Attendance.where(aprv_confirmed: @user.name, aprv_status: "申請中")
    @users = User.where(id: @attendances.select(:user_id))
  end
  
  def update_monthly_aprv
    flag = 0
    monthly_aprv_params.each do |id, item|
      if item[:aprv_chk] == '1'
        unless item[:aprv_status] == "申請中"
          flag += 1
          attendance = Attendance.find(id)
          attendance.aprv_confirmed = nil if item[:aprv_status] == "なし"
          attendance.update_attributes(item)
        end
      end
    end
    if flag > 0
      flash[:success] = "1ヶ月分の勤怠申請を更新しました。"
    else
      flash[:danger] = "1ヶ月分の勤怠申請の更新に失敗しました。"
    end
    redirect_to user_url(date: params[:date])
  end

  private
    
    def overtime_req_params
      params.require(:user).permit(attendances: [:scheduled_at, :overwork_next_day, :worked_contents, :confirmed_request])[:attendances]
    end
    
    def overtime_aprv_params
      params.require(:user).permit(attendances: [:overwork_status, :overwork_chk])[:attendances]
    end
    
    def chg_req_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :chg_next_day, :note, :chg_confirmed])[:attendances]
    end
    
    def chg_aprv_params
      params.require(:user).permit(attendances: [:chg_status, :chg_chk])[:attendances]
    end
    
    def monthly_req_params
      params.require(:user).permit(attendances: :aprv_confirmed)[:attendances]
    end
    
    def monthly_aprv_params
      params.require(:user).permit(attendances: [:aprv_status, :aprv_chk])[:attendances]
    end
    
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      if !current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end
    end
end
