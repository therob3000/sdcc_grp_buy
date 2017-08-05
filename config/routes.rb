Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  resources :users do
    member do
      get 'dashboard'
    end

  end


  resources :members do 
    member do 
    end

    collection do
      get 'cover_member'
      delete 'remove_member'
      post 'register_member_to_group'
      post 'register_member'
    end
  end

  resources :groups do 
    collection do 
      get 'present_member'
      get 'search'
      get 'private_search'
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
