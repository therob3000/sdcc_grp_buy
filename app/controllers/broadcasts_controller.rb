class BroadcastsController < WebsocketRails::BaseController
	def register_member_to_group
		room = message[:room]
		member_group_id = message[:member_group_id]
		connection = message[:connection]
		member_id = message[:member_id]
		grp = Group.find(room)
		number = grp.member_groups.count
		WebsocketRails["group_#{room}"].trigger('member_registered', {room: room, member_group_id: member_group_id, member_id: member_id, connection_id: connection, :num_of_ppl => number})
	end

	def delete_member_from_group
		room = message[:room]
		member_group_id = message[:member_group_id]
		connection = message[:connection]
		grp = Group.find(room)
		number = grp.member_groups.count
		WebsocketRails["group_#{room}"].trigger('unregister_member', {room: room, member_group_id: member_group_id, connection_id: connection, :num_of_ppl => number })
	end

	def mark_member_as_covered_for_all_groups
		member_id = message[:member_id]
	end

	def cover_member_for_group
		room = message[:group_id]
		member_group_id = message[:member_group_id]
		connection = message[:connection]
		grps = message[:groups].split('-')
		grps.each do |room|
			WebsocketRails["group_#{room}"].trigger('member_covered', {member_group_id: member_group_id}, connection_id: connection)
		end
	end

	def someone_typing
		room = message[:room]
		connection = message[:connection]
		WebsocketRails["group_#{room}"].trigger('someone_typing', {room: room, connection_id: connection})
	end

	def deactivate_member
		member = Member.find(message[:member_id])
    member.active = false
    member.sponsor_id = nil
		connection = message[:connection]
    # maybe i need to loop in the JS and not in the controller
    if member.save
	    member.member_groups.map { |e| e.group_id }.each do |grp_id|
				WebsocketRails["group_#{grp_id}"].trigger('deactivate_member', { :member_id => member.id,connection_id: connection })
	    end
    else
    		puts 'ERROR'
    # 	member.member_groups.map { |e| e.group_id }.each do |grp_id|
				# WebsocketRails["group_#{grp_id}"].trigger('activate_member', { :message => member.errors.full_messages })
	   #  end
    end	
	end


	def activate_member
		member = Member.find(message[:member_id])
    member.active = true
    member.sponsor_id = current_user.id
		connection = message[:connection]
    # maybe i need to loop in the JS and not in the controller
    if member.save
	    member.member_groups.map { |e| e.group_id }.each do |grp_id|
				WebsocketRails["group_#{grp_id}"].trigger('activate_member', { :member_id => member.id,connection_id: connection })
	    end
    else
    		puts 'ERROR'
    # 	member.member_groups.map { |e| e.group_id }.each do |grp_id|
				# WebsocketRails["group_#{grp_id}"].trigger('activate_member', { :message => member.errors.full_messages })
	   #  end
    end
	end

	def send_chat_message
		room = message[:room]
		message_id = message[:message]
		user_id = current_user.id
		connection = message[:connection]
		WebsocketRails["group_#{room}"].trigger('add_room_message', {room: room, message_id: message_id, user_id: message[:user_id], connection_id: connection})
		
	end
end
