class UsersController < ApplicationController
	# before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:login, :manual_create,:manual_login]
  before_action :validate, except: [:login, :manual_create,:manual_login, :side_menu]

  def login

  end

  def manual_login
    user = User.find_by_email(login_params['email'])
    if user.valid_password?(login_params['password'])
      sign_in(:user, user)
      redirect_to :back
    else
      flash[:error] = 'Email or password invalid'
      redirect_to :back
    end
  end

  def manual_create
    user = User.new(user_params)
    if (user_params['avatar_url'].nil?) || (user_params['avatar_url'] == '')
      user.avatar_url = Faker::Avatar.image("my-own-slug", "50x50")
    end

    if user.save
      sign_in(:user, user)
      redirect_to :back
    else
      flash[:error] = user.errors.full_messages.join(', ')
      redirect_to :back
    end
  end

  def dashboard
  	
  end

  def edit
  	
  end

  def update
  	
  end

  def destroy
  	
  end

  def show
    
  end

  def side_menu
    @user = current_user
    @members = current_user.members
    @groups = current_user.groups
  end

  def inbox
    if params[:page]
      @dms = current_user.direct_messages.order('created_at DESC').paginate(:page => params[:page], :per_page => 10)   
    else
      @dms = current_user.direct_messages.order('created_at DESC').paginate(:page => 1, :per_page => 10)   
    end
    # @dms = 
    # @dms = current_user.direct_messages
  end

  def show_user
    @user = User.find(params[:id])
    render :partial => 'show', :locals => {:user => @user}
  end

  private 

  def login_params
    params.require(:login).permit(:email,:password)
  end

  def user_update_params
    params.require(:update).permit(:name,:email,:avatar_url)
    
  end

  def user_params
    params.require(:signup).permit(:name,:email,:avatar_url,:password,:password_confirmation)
  end
end
