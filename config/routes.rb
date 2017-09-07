Rails.application.routes.draw do
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


  resources :members do 
    collection do
      get 'cover_member'
      delete 'remove_member'
      post 'register_member_to_group'
      post 'register_member'
      get 'validate_user'
      get 'search'
      get 'activate_member'
      post 'direct_message'
      get 'mark_message_seen'
    end
  end

  resources :admins do 
    member do 
      get 'send_email'
      patch 'promote'
      patch 'demote'
      delete 'banish'
      delete 'blow_up_group'
      delete 'delete_member'
    end
    collection do 
      get 'search'
      get 'search_users'
      get 'search_members'
      get 'search_groups'
      get 'users_index'
      get 'members_index'
      get 'groups_index'
      get 'members_index'
      get 'groups_index'
    end
  end

  resources :groups do 
    collection do 
      get 'add_comment'
      get 'present_member'
      get 'search'
      get 'private_search'
      post 'process_message'
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
