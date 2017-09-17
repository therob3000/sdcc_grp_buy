class Group < ApplicationRecord
	belongs_to :user
	has_many :member_groups
	has_many :chat_messages

	validates_uniqueness_of :name

	def has_active_member
		member_groups.map { |e| e.member }.any? { |e| e.try(:active) }
	end

	def is_fully_covered
		member_groups.all? { |e| e.member.try(:covered) }
	end

	def number_covered
		member_groups.select { |e| e.member.try(:covered) }.count
	end

	def coverage
		if member_groups.all? { |e| e.member.try(:covered) } && member_groups.count > 0
			color = '#6dff94'
		else
			color = '#ecf0f5'
		end
		color
	end

	def member_lists
		member_groups.map { |e| "member_groups_marker_#{e.id}" }.join(' ')
	end
end
