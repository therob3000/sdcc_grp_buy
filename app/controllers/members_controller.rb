class MembersController < ApplicationController
	before_action :authenticate_user!
	before_action :validate, :only => [:register_member,:register_member_to_group,:remove_member,:cover_member]
	include SecurityHelper
	
	def index
		if params[:page]
			@members = Member.paginate(:page => params[:page], :per_page => 10)		
		else
			@members = Member.paginate(:page => 1, :per_page => 10)		
		end
	end

	def activate_member
		@member = Member.find(params[:id])
		@member.active = true

		if @member.save
			render :json => { :success => true }
		else
			render :json => { :success => false, :message => @member.errors.full_messages}
		end
		
	end

	def validate_user
		code = code_params['code']
		db_code = ValidationCode.find_by_email(current_user.email)
		if db_code.code == decrypt_code(code)
			current_user.validation_code = code
			current_user.save
		else
			flash[:error] = 'Code is invalid, or expired'
		end

		redirect_to :back
	end

	def mark_message_seen
		dm = DirectMessage.find(params[:id])
		dm.seen = true

		if dm.save
			render :json => { :success => true }
		else
			render :json => { :success => false, :message => dm.errors.full_messages}
		end
	end

	def register_member
		# user_id: integer, sdcc_member_id: integer, name: string, phone: string, email: string, covered: boolean,
		@member = Member.new(member_params)
		@member.user_id = current_user.id
		@member.covered = false

		if @member.save
			render :json => { :success => true, :member_id => @member.sdcc_member_id }
		else
			render :json => { :success => false, :message => @member.errors.full_messages}
		end

	end

	def direct_message
		# user_id: integer, from_user_id: integer, subject: string, body: text,
		dm = DirectMessage.new(direct_message_params)
		dm.from_user_id = current_user.id
		if dm.save
			render :json => { :success => true }
		else
			render :json => { :success => false, :message => dm.errors.full_messages}
		end
	end

	def search
		if !!(params[:search] =~ /\A[-+]?[0-9]+\z/)
			@members = Member.where('lower(sdcc_member_id) like ?', "%#{params[:search].downcase}%").first(8)
		else
			@members = Member.where('lower(name) like ?', "%#{params[:search].downcase}%").first(8)
		end
		# render :partial => "group_list", :locals => { :members => @members }
		render :partial => 'members/member_list_part', :locals => { :members => @members}
	end

	def register_member_to_group

		# every group can have a max of 5 members in it
		@group = Group.find(params[:member_group][:group_id])
		# @member = Member.create(member_params)
		if @group.member_groups.count >= 40
			render :json => {:success => false, :message => ["Sorry, this group is full"]}
		else
			if Member.exists?(:sdcc_member_id => params[:sdcc_member_id])
				@member = Member.find_by_sdcc_member_id(params[:sdcc_member_id])
				# a member can belong to no more than 3 groups
				if @member.member_groups.count >= 20
					render :json => {:success => false, :message => ['This member is already signed up with 5 groups, and cannot be in anymore.']}
				else 
					mb = MemberGroup.new(member_groups_params)
					mb.member_id = @member.id
					mb.user_id = current_user.id
					if mb.save 
						# create the need
						need = Need.new(need_params)
						need.member_id = @member.id
						if need.save
							render :json => {:success => true, :member_id => @member.id, :member_group_id => mb.id}
						else
							render :json => {:success => false, :message => need.errors.full_messages}
						end
					else
						render :json => {:success => false, :message => mb.errors.full_messages}
					end
				end
			else
				render :json => {:success => false, :new_member => true}
			end
		end
	end

	def remove_member
		mb_id = params[:mem_grp_id]
		mb = MemberGroup.find(mb_id)
		group = mb.group
		if current_user.groups.include?(group)
			mb.delete
			render :json => {:success => true, :message => mb_id}
		else
			render :json => {:success => false, :message => 'could not delete'}
		end
	end

	def show
		@mem = Member.find(params[:id])
		render :partial => 'show', :locals => {:member => @mem}
	end

	def cover_member
		member = Member.find(params[:member_id])
		member.covered = true;
		pur = Purchase.new(:user_id => current_user.id, :need_id => params[:need_id])
		if member.save
			pur.save
			render :json => { :success => true, :member_group_id => params[:member_group_id], :groups => member.member_groups.map { |e| e.group_id }.join('-'), :group_id => params[:group_id] }
		else
			errs = []

			pur.errors.full_messages.each do |e|
				errs << e
			end


			member.errors.full_messages.each do |e|
				errs << e
			end
			render :json => { :success => false, :message => errs }
		end

	end

	private
	def code_params
		params.require(:code).permit(:code)
	end

	def member_params
		params.require(:member).permit(:name, :last_name, :sdcc_member_id, :phone, :email)
	end

	def member_groups_params
		params.require(:member_group).permit(:group_id)
	end

	def direct_message_params
		# user_id: integer, from_user_id: integer, subject: string, body: text,
		params.require(:message).permit(:subject, :body, :user_id)

	end

	def need_params
		params.require(:need).permit(:wensday, :thursday, :friday, :saturday, :sunday)
		
	end
end
