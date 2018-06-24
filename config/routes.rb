Rails.application.routes.draw do

  namespace :line_day do
    resources :time_slots do
      collection do 
        post 'broadcast_to_slot'
      end
    end
  end

  resources :line_days

  resources :holders do 
    collection do 
      get 'erase'
      post 'send_text'
    end
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  resources :users do
    member do
      get 'dashboard'
    end

    collection do
      post 'update_user'
      post 'manual_create'
      post 'manual_login'
      get 'confirm_create'
      get 'inbox' 
      get 'show_user'
      get 'side_menu'
    end

  end

  resources :purchases do 
    collection do 
      get 'search'
      get 'send_out_confirmation'
    end
  end

  resources :members do 
    collection do
      get 'cover_member'
      get 'find_me'
      delete 'remove_member'
      post 'register_member_to_group'
      post 'register_member'
      get 'validate_user'
      get 'search'
      get 'search_smaller'
      post 'make_purchase'
      get 'find_member_name'
      get 'activate_member'
      post 'direct_message'
      get 'mark_message_seen'
      get 'present_confirmation_partial'
    end
  end

  resources :admins do 
    member do 
      get 'send_email'
      get 'send_invite'
      patch 'promote'
      patch 'demote'
      delete 'banish'
      delete 'delete_invite'
      delete 'blow_up_group'
      delete 'delete_member'
    end
    
    collection do 
      post 'upload_csv'
      post 'create_invite'
      get 'search'
      get 'grab_csv_progress'
      get 'search_users'
      get 'search_members'
      get 'search_groups'
      get 'csv_upload'
      get 'users_index'
      get 'members_index'
      get 'groups_index'
      get 'members_index'
      get 'groups_index'
    end
  end

  resources :groups do 
    collection do 
      get 'get_count'
      get 'add_comment'
      get 'present_member'
      post 'follow_group'
      get 'search'
      get 'private_search'
      get 'present_master_partial'
      get 'present_member_list_partial'
      post 'process_message'
      get 'master_tab'
      get 'present_day_container'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'users#login'


 #  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
	# match 'auth/failure', to: redirect('/'), via: [:get, :post]
	# match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :post]

  devise_scope :users do
    get 'user_log_out_route/sign_out', :to => 'devise/sessions#destroy'
  end
end
