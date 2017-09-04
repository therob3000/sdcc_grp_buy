class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  layout 'application'
  # private
  # def current_user
  #   @current_user ||= User.find(session[:user_id]) if session[:user_id]
  # end
  
  # helper_method :current_user

  # private

  def validate
  	if !current_user.is_valid?
  		flash[:error] = 'You must validate your code, or request a code'
  		redirect_to root_path
  	end
  end

end
