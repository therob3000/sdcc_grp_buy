class GroupsController < ApplicationController
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

	def private_search
		@groups = Group.where('lower(name) like ? and user_id = ?', "%#{params[:search]}%", current_user.id)
		# render :partial => "group_list_sidebar", :locals => { :groups => @groups }
		render :partial => 'groups/group_list_sidebar', :locals => { :groups => @groups}
	end

	def present_member
		mem_grp = MemberGroup.find(params[:mem_grp_id])
		grp = Group.find(params[:grp_id])
		render :partial => 'member_list_item', :locals => { :mem_grp => mem_grp, :grp => grp }
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

	def show
		@grp = Group.find(params[:id])
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

	def group_params
		params.require(:group).permit(:name)
	end
end
