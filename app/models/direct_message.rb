class DirectMessage < ApplicationRecord
	belongs_to :user
	validates :from_user_id, presence: true

	def from_user
		User.find(from_user_id)
	end

end
