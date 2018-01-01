class GroupsController < ApplicationController
	before_action :authenticate_user!
	before_action :validate, :only => [:create_new_group]
	
	def index
		if params[:page]
			@groups = Group.paginate(:page => params[:page], :per_page => 10)		
		else
			@groups = Group.paginate(:page => 1, :per_page => 10)		
		end
	end

	def search
		@groups = Group.where('lower(name) like ?', "%#{params[:search].downcase}%").first(8)
		# render :partial => "group_list", :locals => { :groups => @groups }
		render :partial => 'groups/group_list_sidebar', :locals => { :groups => @groups}
	end

	def get_count
		@group = Group.find(params[:group_id])
		count = @group.count_string

		render :json => { :count => count }
	end

	def present_day_container
		member_id = params[:member_id]
		member = Member.find(member_id)

		render :partial => 'groups/days_container', :locals => { :member => member }
	end

	def follow_group
		@group = Group.find(follow_params[:group_id])
		@group_follow = FollowedGroup.new(follow_params)
		if @group_follow.save
			render :json => { :message => "#{@group.name} followed by you", :group_id => @group.id }
		end
	end

	def private_search
		# @groups = Group.where('lower(name) like ? and user_id = ?', "%#{params[:search]}%", current_user.id)
		@groups = Group.where('lower(name) like ?', "%#{params[:search]}%")
		# render :partial => "group_list_sidebar", :locals => { :groups => @groups }
		render :partial => 'groups/group_list_sidebar', :locals => { :groups => @groups}
	end

	def present_member
		mem_grp = MemberGroup.find(params[:mem_grp_id])
		grp = Group.find(params[:grp_id])
		render :partial => 'member_list_item', :locals => { :mem_grp => mem_grp, :grp => grp, :member => mem_grp.member }
	end

	def create
		@grp = Group.new(group_params)
		@grp.user_id = current_user.id
		if @grp.save
			render :json => { :success => true}
		else 
			render :json => { :success => false, :message => @grp.errors.full_messages}
		end
	end

	def present_master_partial
		grp = Group.find(params[:group_id])
		render :partial => 'groups/master_tab_group', :locals => { :grp => grp }
	end

	def present_member_list_partial
		# update the group order based on the jason obj provided
		order_obj = JSON.parse(params[:order])
		grp = Group.find(params[:group_id])

		# search current users order preferences obj and parse it 
		if current_user.order_prefs
			# reassign
			preferences = JSON.parse(current_user.order_prefs.to_s)
			preferences[params[:group_id]] = order_obj
		else
			preferences = {}
		end
		# save
		current_user.update_attributes(:order_prefs => preferences.to_json)
		group_order = preferences
		# re render
		render :partial => 'main_member_list', :locals => {:grp => grp,:order => group_order}
	end

	def process_message
		mess = ChatMessage.new(message_params)
		mess.user_id = current_user.id
		if params[:type] == 'global'
			mess.global_scope = true
			mess.group_id = nil
		end

		type = params[:type]

		if mess.save
			render :json => { :success => true, :message => mess.id, :user_id => current_user.id, :type => type }
		else 
			render :json => { :success => false, :message => mess.errors.full_messages, :type => type }
		end		
	end

	def master_tab
		@groups = Group.all
		@page = 'master_tab'
		@global_chat_messages = ChatMessage.global_chats
	end

	def add_comment
		message = ChatMessage.find(params[:message_id])
		render :partial => 'groups/chat_line', :locals => { :message => message, :user => message.user, :from => params[:from] }
	end

	def show
		@grp = Group.find(params[:id])
		@page = 'group_show_page'
		@grp_order = nil
		if current_user.order_prefs
			prefs = JSON.parse(current_user.order_prefs.try(:to_s))
			@grp_order = prefs[@grp.id]
		end
		
		# if the group order preferences is blank, then just run the order as normal
		@global_chat_messages = ChatMessage.global_chats
		# @messages = ChatMessage.select { |e| e.group_id == @grp.id } 
	end

	def create_new_group
		@grp = Group.new(group_params)
		@grp.user_id = current_user.id

		if @grp.save
			render :json => { :success => true}
		else 
			render :json => { :success => false, :message => @grp.errors.full_messages}
		end
		
	end

	private

	def follow_params
		params.require(:follow).permit(:user_id, :group_id)
	end

	def message_params
		params.require(:message).permit(:message, :group_id)
	end

	def group_params
		params.require(:group).permit(:name)
	end
end
