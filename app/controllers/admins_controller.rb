class AdminsController < ApplicationController
	require "csv"
	before_action :authenticate_user!, :validate_admin
	include SecurityHelper

	def members_index
		if params[:page]
			@members = Member.paginate(:page => params[:page], :per_page => 5)		
		else
			@members = Member.paginate(:page => 1, :per_page => 5)		
		end
	end

	def search_members
		members = Member.where("lower(sdcc_member_id) like ? OR lower(name) like ?", "%#{params[:search].downcase}%", "%#{params[:search].downcase}%").first(5)
		render :partial => 'code_results_members', :locals => { :members => members }
	end

	def delete_member
		member = Member.find(params[:id])
		if member.delete
			render :json => { :success => true, :message => 'member destroyed!', :delete_id => member.id }
		else
			render :json => { :success => false, :message => member.errors.full_messages.join(',') }
		end
	end

	def upload_csv
    myfile = params[:file]
		@rowarraydisp = CSV.read(myfile.path)
		keys = []
		errors = []
		success = []
		 	
		@rowarraydisp.each_with_index do |row,idx|
			if idx == 0
				keys = row	
			else			
				obj = {}
				row.each_with_index do |r,number|
					obj[keys[number]] = r
				end

				# create the member
				creation_obj = {
					:user_id => current_user.id,
					:sdcc_member_id => obj['CC Member ID'],
					:email => obj['CC email address'],
					:name => obj['First name'], 
					:last_name => obj['Last name'], 
					:wensday => true, 
					:thursday => true, 
					:friday => true, 
					:saturday => true, 
					:sunday => true
				}
				mem = Member.new(creation_obj)
				if mem.save
					success << "Created member: #{obj['CC Member ID']}"
				else
					errors << "#{obj['CC Member ID']}: #{mem.errors.full_messages.join(',')}"
				end
			end
		end

		 	
		# render :json => { :errors => error, :success => success }
		flash[:errors] = errors
		flash[:success] = success
		redirect_to :back
	end

	def groups_index
		if params[:page]
			@groups = Group.paginate(:page => params[:page], :per_page => 5)		
		else
			@groups = Group.paginate(:page => 1, :per_page => 5)		
		end
		
	end

	def search_groups
		groups = Group.where("lower(name) like ?", "%#{params[:search].downcase}%").first(5)
		render :partial => 'code_results_groups', :locals => { :groups => groups }
	end

	def blow_up_group
		group = Group.find(params[:id])
		if group.delete
			render :json => { :success => true, :message => 'group destroyed!', :delete_id => group.id }
		else
			render :json => { :success => false, :message =>group.errors.full_messages.join(',') }
		end
	end

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

	def users_index
		if params[:page]
			@users = User.paginate(:page => params[:page], :per_page => 5)		
		else
			@users = User.paginate(:page => 1, :per_page => 5)		
		end
	end

	def promote
		user = User.find(params[:id])
		user.is_admin = true
		if user.save
			render :json => { :success => true, :message => 'user promoted!', :admin_id => user.id }
		else
			render :json => { :success => false, :message =>user.errors.full_messages.join(',') }
		end	
	end

	def demote
		user = User.find(params[:id])
		user.is_admin = false
		if user.save
			render :json => { :success => true, :message => 'user promoted!', :admin_id => user.id }
		else
			render :json => { :success => false, :message =>user.errors.full_messages.join(',') }
		end	
	end

	def banish
		user = User.find(params[:id])
		if user.delete
			render :json => { :success => true, :message => 'user banished!', :delete_id => user.id }
		else
			render :json => { :success => false, :message =>user.errors.full_messages.join(',') }
		end
	end

	def search_users
		users = User.where("lower(name) like ?", "%#{params[:search].downcase}%").first(5)
		render :partial => 'code_results_users', :locals => { :users => users }
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

		obj = {
			email: email, 
			message: "your validation code is: #{encrypt_code(val_code.code)}"
		}

		send_email_to_email(obj)

		if val_code.save
			render :json => { :success => true, :message => "email sent to #{email}", :code => code, :id => val_code.id }
		else
			render :json => { :success => false, :message =>val_code.errors.full_messages.join(',') }
		end
	end

	def send_email_to_email(obj)
		MyMailer.send_email(obj).deliver
	  # redirect_to root_url, notice: "Email sent!"
	end

	def destroy
		# deletes the code
		val_code = ValidationCode.find(params[:id])
		code = ''
		if val_code.delete
			render :json => { :success => true, :message => 'deleted', :code => code, :delete_id => val_code.id }
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
