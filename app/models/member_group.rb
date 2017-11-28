class MemberGroup < ApplicationRecord
	belongs_to :user
	belongs_to :member
	belongs_to :group

	validates_uniqueness_of :member_id, :scope => :group_id

	validate :member_not_in_any_group

	def member_not_in_any_group
		if member.member_groups >= 1
			gname = member.member_groups.first.group.name
      errors.add(:group_id, "member already belongs to #{gname}")
    end
	end
end
