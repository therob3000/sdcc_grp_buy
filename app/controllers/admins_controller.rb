class AdminsController < ApplicationController
	before_action :authenticate_user!, :validate_admin
	include SecurityHelper

	def index
		if params[:page]
			@codes = ValidationCode.paginate(:page => params[:page], :per_page => 5)		
		else
			@codes = ValidationCode.paginate(:page => 1, :per_page => 5)		
		end
	end

	def search
		codes = ValidationCode.where("lower(email) like ?", "%#{params[:search].downcase}%").first(5)
		render :partial => 'code_results', :locals => { :codes => codes }
	end

	def create
		val_code = ValidationCode.new(code_params)
		code = gen_code
		val_code.code = code
		if val_code.save
			flash[:update] = 'saved'
		else
			flash[:error] = val_code.errors.full_messages.join(',')
		end

		redirect_to :back
	end

	def update
		# resets the code
		val_code = ValidationCode.find(params[:id])
		code = gen_code
		val_code.code = code
		if val_code.save
			render :json => { :success => true, :message => "code reset for #{val_code.email}", :code => code, :id => val_code.id }
		else
			render :json => { :success => false, :message =>val_code.errors.full_messages.join(',') }
		end
	end

	def send_email
		# sends the code
		val_code = ValidationCode.find(params[:id])
		email = val_code.email
		code = ''
		if val_code.save
			render :json => { :success => true, :message => "email sent to #{email}", :code => code, :id => val_code.id }
		else
			render :json => { :success => false, :message =>val_code.errors.full_messages.join(',') }
		end
	end

	def destroy
		# deletes the code
		val_code = ValidationCode.find(params[:id])
		code = ''
		if val_code.delete
			render :json => { :success => true, :message => 'deleted', :code => code, :id => val_code.id }
		else
			render :json => { :success => false, :message =>val_code.errors.full_messages.join(',') }
		end
	end


	private

	def code_params
		params.require(:code).permit(:email)
	end

	def validate_admin
		if !current_user.is_admin?
			redirect_to root_path
		end
	end
end
