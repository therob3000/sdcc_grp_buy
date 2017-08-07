class BroadcastsController < WebsocketRails::BaseController
	def register_member_to_group
			room = message[:room]
			member_group_id = message[:member_group_id]
			member_id = message[:member_id]
			WebsocketRails["group_#{room}"].trigger('member_registered', {room: room, member_group_id: member_group_id, member_id: member_id})
	end

	def delete_member_from_group
			room = message[:room]
			member_group_id = message[:member_group_id]
			WebsocketRails["group_#{room}"].trigger('unregister_member', {room: room, member_group_id: member_group_id})
	end

	def mark_member_as_covered_for_all_groups
		member_id = message[:member_id]
	end

	def cover_member_for_group
		room = message[:group_id]
		member_group_id = message[:member_group_id]
		grps = message[:groups].split('-')
		grps.each do |room|
			WebsocketRails["group_#{room}"].trigger('member_covered', {member_group_id: member_group_id})
		end
	end

	def someone_typing
		room = message[:room]
		WebsocketRails["group_#{room}"].trigger('someone_typing', {room: room})
		
	end

	def send_chat_message
		room = message[:room]
		message_id = message[:message]
		user_id = message[:user_id]
		connection = message[:connection]
		WebsocketRails["group_#{room}"].trigger('add_room_message', {room: room, message_id: message_id, user_id: user_id, connection_id: connection})
		
	end
end
