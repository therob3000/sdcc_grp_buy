class Invite < ApplicationRecord
	belongs_to :user

	validate :user_is_admin

	def user_is_admin
		if !user.is_admin
			errors.add(:user_id, "must be admin.")
		end
	end

	def accepted?
		if User.exists?(:email => email)
			true
		else
			false
		end
	end

end
