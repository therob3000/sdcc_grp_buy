class MembersController < ApplicationController
	before_action :authenticate_user!
	before_action :validate, :only => [:register_member,:register_member_to_group,:remove_member,:cover_member, :present_confirmation_partial, :find_member_name]

	before_action :user_owns, :only => [:edit, :update]

	include SecurityHelper
	
	def index
		if params[:page]
			@members = Member.paginate(:page => params[:page], :per_page => 10)		
		else
			@members = Member.paginate(:page => 1, :per_page => 10)		
		end
	end

	def edit
	end

	def update
		@member.assign_attributes(member_params)

		if @member.save
			flash[:error] = 'Information Saved'
		else
			flash[:error] = @member.errors.full_messages.join(', ')	
		end
		
		redirect_to :back
	end

	def present_confirmation_partial
		mem = Member.find(params[:member_id])
		memgrp = MemberGroup.find(params[:mem_group_id])
		render :partial => 'buy_confirm', :locals => {:member => mem, :mem_grp => memgrp}
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
		render :partial => 'members/member_list_part', :locals => { :members => @members }
	end


	def search_smaller
		if !!(params[:search] =~ /\A[-+]?[0-9]+\z/)
			@members = Member.where('lower(sdcc_member_id) like ?', "%#{params[:search].downcase}%").first(4)
		else
			@members = Member.where('lower(name) like ?', "%#{params[:search].downcase}%").first(4)
		end
		# render :partial => "group_list", :locals => { :members => @members }
		render :partial => 'members/member_list_part_small', :locals => { :members => @members, :type => 'smaller'}
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
						render :json => {:success => true, :member_id => @member.id, :member_group_id => mb.id}
						return
					else
						render :json => {:success => false, :message => mb.errors.full_messages}
						return
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

	def find_member_name
		@mem = Member.find(params[:id])
		render :json => {:success => true, :name => "#{@mem.name} #{@mem.last_name}"}
	end

	def make_purchase
		member = Member.find(purchase_params['member_id'])
		mem_grp = MemberGroup.find(params[:member_group_id])
		member.covered = true;
		pur = Purchase.new(purchase_params)
		pur.user_id = current_user.id
		if purchase_params['member_id'].nil?
			# then it was the current user that purchased for them
			put.notes += "\n Purchased by #{current_user.name} Contact at #{current_user.email}"
		end

		if member.save && pur.save
			# SEND EMAIL TO THE USER
			purchasing_member_notes = ''
			if purchase_params["covering_id"].nil?
				purchasing_member_notes = current_user.payment_info
				purchasing_member_first_name = current_user.name
				purchasing_member_name = "#{current_user.name} (#{current_user.email})"
				add_notes = current_user.payment_info
			else
				pur_mem = Member.find(purchase_params["covering_id"])
				purchasing_member_notes = pur_mem.payment_info
				purchasing_member_first_name = pur_mem.name
				purchasing_member_name = "#{pur_mem.name} #{pur_mem.last_name} (#{pur_mem.email}. #{ pur_mem.phone ? 'phone:' + pur_mem.phone : ''})"
				add_notes = pur_mem.payment_info
			end
 


      obj = {
        email: member.email, 
        member: member,
        purchase: pur,
        purchasing_member_notes: purchasing_member_notes,
        purchasing_member_first_name: purchasing_member_first_name,
        purchasing_member_name: purchasing_member_name,
        add_notes: add_notes
      }

      MyMailer.send_confirmation(obj, "CONGRATULATIONS!  #{purchasing_member_first_name} has covered you for SDCC 2018!!").deliver

			# render out
			render :json => { :success => true, :member_group_id => mem_grp.id, :groups => member.member_groups.map { |e| e.group_id }.join('-'), :group_id => params[:group_id], :member_id => member.id }
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

	def user_owns
		@member = Member.find(params[:id])

		if @member.user_id != current_user.id
			flash[:error] = 'your not authorized for this'
			redirect_to :back
		end
	end

	def purchase_params
		params.require(:conf).permit(:confirmation_code,:price,:covering_id,:notes,:member_id)
	end

	def code_params
		params.require(:code).permit(:code)
	end

	def member_params
		params.require(:member).permit(:name, :last_name, :sdcc_member_id, :phone, :email, :wensday, :thursday, :friday, :saturday, :sunday, :payment_info)
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
