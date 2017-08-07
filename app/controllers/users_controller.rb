class UsersController < ApplicationController
	# before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:login]

  def login

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
end
