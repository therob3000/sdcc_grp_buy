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
  	byebug
  end
end
