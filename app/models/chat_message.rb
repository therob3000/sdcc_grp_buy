class ChatMessage < ApplicationRecord
	belongs_to :group
	belongs_to :user
	order("events.created_at ASC")

end
