class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :update_basic_info, :attendance_log]
  before_action :logged_in_user, only: [
    :index, :csv_import, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :attendance_list, :attendance_log
  ]
  before_action :correct_user, only: [:edit, :update]
  before_action :all_users, only: [:index, :attendance_list]
  before_action :admin_user, only: [:show, :attendance_log]
  before_action :non_admin_user, only: [:index, :csv_import, :destroy, :edit_basic_info, :update_basic_info, :attendance_list]
  before_action :superior_user, only: :show
  before_action :set_one_month, only: :show
  
  def index
  end
  
  def csv_import
    if params[:file].present?
      flash[:success] = 'CSVファイルを読み込みました。'
      User.import(params[:file])
    else
      flash[:danger] = 'CSVファイルの読み込みに失敗しました。'
    end
    redirect_to users_url
  end
  
  def show
    respond_to do |format|
      format.html
      format.csv do
        csv_export(@attendances)
      end
    end
    @attendance = @user.attendances.find_by(worked_on: @first_day)
    @worked_sum = @attendances.where.not(started_at: nil).count
    @overwork_sum = Attendance.where(worked_on: @first_day..@last_day, confirmed_request: @user.name, overwork_status: "申請中").count
    @chg_sum = Attendance.where(worked_on: @first_day..@last_day, chg_confirmed: @user.name, chg_status: "申請中").count
    @aprv_sum = Attendance.where(worked_on: @first_day..@last_day, aprv_confirmed: @user.name, aprv_status: "申請中").count
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end
  
  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name_was}の更新は失敗しました。<br>" +
      @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  def attendance_list
  end
  
  def attendance_log
    if params["select_year(1i)"].present? && params["select_month(2i)"].present?
      @first_day = (params["select_year(1i)"] + "-" + params["select_month(2i)"] + "-01").to_date
      @attendances = @user.attendances.where(worked_on: @first_day..@first_day.end_of_month, chg_status: "承認").order(:worked_on)
    end
  end
  
  private
    
    def csv_export(attendances)
      csv_data = CSV.generate(force_quotes: true, encoding:Encoding::SJIS) do |csv|
        csv.add_row(["日付", "出社", "退社"])
        attendances.each do |day|
          date = working_day(day.worked_on)
          if day.chg_status.nil?
            start = working_show(day.b4_started_at, "%H:%M")
            finish = working_show(day.b4_finished_at, "%H:%M")
          elsif day.chg_status == "承認"
            start = working_show(day.started_at, "%H:%M")
            finish = working_show(day.finished_at, "%H:%M")
          else
            start = nil
            finish = nil
          end
          csv.add_row([date, start, finish])
        end
      end
      send_data(csv_data, filename: "当月分勤怠データ.csv")
    end
    
    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(
        :name, :email, :affiliation, :employee_number, :uid, :password,
        :basic_work_time, :designated_work_start_time, :designated_work_end_time
      )
    end
end
