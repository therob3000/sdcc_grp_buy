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
		member = Member.find(message[:member_id])
		member.covered = true
		if member.save
			WebsocketRails.trigger('member_covered', {room: room, member_group_id: member_group_id})
		end
	end
end
