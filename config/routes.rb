Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  resources :users do
    collection {post :csv_import}
    member do
      get 'attendance_list'
      get 'attendance_log'
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_overtime_req'
      patch 'attendances/update_overtime_req'
      get 'attendances/edit_overtime_aprv'
      patch 'attendances/update_overtime_aprv'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      get 'attendances/edit_chg_aprv'
      patch 'attendances/update_chg_aprv'
      patch 'attendances/update_monthly_req'
      get 'attendances/edit_monthly_aprv'
      patch 'attendances/update_monthly_aprv'
    end
    resources :attendances, only: :update
  end
  resources :hubs
end