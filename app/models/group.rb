class Group < ApplicationRecord
	belongs_to :user
	has_many :member_groups
	has_many :chat_messages

	validates_uniqueness_of :name

	def has_active_member
		member_groups.map { |e| e.member }.any? { |e| e.active }
	end

	def member_lists
		member_groups.map { |e| "member_groups_marker_#{e.id}" }.join(' ')
	end
end
