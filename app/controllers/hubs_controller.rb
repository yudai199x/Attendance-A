class HubsController < ApplicationController
  before_action :logged_in_user, only: [:index, :create, :edit, :update, :destroy]
  before_action :non_admin_user, only: [:index, :create, :edit, :update, :destroy]
  before_action :set_hub, only: [:edit, :update, :destroy]
  
  def index
    @hubs = Hub.all
    @hub = Hub.new
  end
  
  def create
    @hub = Hub.new(hub_params)
    if @hub.save
      flash[:success] = '拠点登録完了しました。'
    else
      flash[:danger] = '拠点登録に失敗しました。'
    end
    redirect_to hubs_url
  end
  
  def edit
  end
  
  def update
    if @hub.update_attributes(hub_params)
      flash[:success] = "拠点情報を更新しました。"
    else
      flash[:danger] = "拠点情報の更新は失敗しました。"
    end
    redirect_to hubs_url
  end
  
  def destroy
    @hub.destroy
    flash[:success] = "拠点情報を削除しました。"
    redirect_to hubs_url
  end
  
  private
    
    def hub_params
      params.require(:hub).permit(:number, :name, :worked_type)
    end
    
    def set_hub
      @hub = Hub.find(params[:id])
    end
end
