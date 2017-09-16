class ChatMessage < ApplicationRecord
	belongs_to :group
	belongs_to :user
	order("events.created_at ASC")

	def self.global_chats
		where("global_scope = ?",true)
	end

end
