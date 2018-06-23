class UsersController < ApplicationController
	# before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:login, :manual_create,:manual_login,:confirm_create]
  before_action :validate, except: [:login, :update, :manual_create,:manual_login, :side_menu, :confirm_create, :update_user]
  include SecurityHelper

  def login
  end

  def manual_login
    user = User.find_by_email(login_params['email'])
    if user && user.valid_password?(login_params['password'])
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

    if user.valid?
      # make a validation code
      # make an entry in the user_holder_table with validation code and 
      flash[:error] = "An Email has been sent to #{user_params['email']} with a verification link, please check that e-mail and click the link."
      temp = Temp.new(:name => user.name, :password => user.password, :avatar_url => user.avatar_url, :email => user.email)
      temp.avatar_url = user.avatar_url
      en_code = encrypt_code(gen_code)
      temp.val_code = en_code
      temp.save

      obj = {
        email: user_params['email'], 
        request: request,
        temp: temp,
        en_code: en_code
      }

    MyMailer.val_link(obj, 'Your validation link from SDCC tickets').deliver

      redirect_to :back
    else
      flash[:error] = user.errors.full_messages.join(', ')
      redirect_to :back
    end
  end

  def confirm_create
    code = params[:val]
    id = params[:id]
    temp = Temp.find(id)
    # compare params[:confirmation_code] with what is in user_holder_table for this id 
    if code == temp.val_code
      user = User.new(:name => temp.name, :password => temp.password, :password_confirmation => temp.password, :avatar_url => temp.avatar_url, :email => temp.email)
      if user.save
        # find member with the email of this user
        if Member.exists?(:email => user.email)
          mem = Member.find_by_email(user.email)
          mem.user_id = user.id
          mem.save
        end
        sign_in(:user, user)
        redirect_to '/'
      else
        flash[:error] = user.errors.full_messages.join(', ')
        redirect_to '/'
      end
    else
      flash[:error] = 'Invalid Code'
      redirect_to '/'
    end
  end

  def dashboard
  	
  end

  def edit
  	
  end

  def update_user
    current_user.assign_attributes(user_update_params)
  	if current_user.save
      redirect_to :back
    else
      flash[:error] = current_user.errors.full_messages.join(', ')
      redirect_to :back
    end
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
    params.require(:update).permit(:name,:email,:avatar_url,:payment_info, :phone)
    
  end

  def user_params
    params.require(:signup).permit(:name,:email,:avatar_url,:password,:password_confirmation, :phone)
  end
end
