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

	def group_updated
		group_id = message[:room]
		count = message[:count]
		total = count.split('/')[1]
		covered = count.split('/')[0]
		if covered == total
			complete = true
		else
			complete = false
		end

		obj = {
			group_id: group_id, 
			count: count,
			complete: complete
		}
		WebsocketRails["global"].trigger('group_updated', obj)
	end

	def cover_member_for_group
		room = message[:group_id]
		member_group_id = message[:member_group_id]
		member_id = MemberGroup.find(message[:member_group_id]).member.id
		connection = message[:connection]
		WebsocketRails["global"].trigger('member_covered', {member_id: member_id, member_group_id: member_group_id, group_id: room, connection_id: connection})
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
				WebsocketRails["global"].trigger('deactivate_member', { :member_id => member.id,connection_id: connection })
    else
    		puts 'ERROR'
    end	
	end


	def activate_member
		member = Member.find(message[:member_id])
    member.active = true
    member.sponsor_id = current_user.id
		connection = message[:connection]
    # maybe i need to loop in the JS and not in the controller
    if member.save
				WebsocketRails["global"].trigger('activate_member', { :member_id => member.id,connection_id: connection })
    else
    		puts 'error'
    		puts member.errors.full_messages.join(',')
    end
	end

	def send_chat_message
		type = message[:type]
		room = message[:room]
		message_id = message[:message]
		user_id = current_user.id
		connection = message[:connection]
		if type == 'group'
			WebsocketRails["group_#{room}"].trigger('add_room_message', {room: room, message_id: message_id, user_id: message[:user_id], connection_id: connection})
		else
			WebsocketRails["global"].trigger('add_global_message', {message_id: message_id, user_id: message[:user_id], connection_id: connection})
		end
		
	end
end
