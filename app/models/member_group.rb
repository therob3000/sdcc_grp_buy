class MemberGroup < ApplicationRecord
	belongs_to :user
	belongs_to :member
	belongs_to :group

	validates_uniqueness_of :member_id, :scope => :group_id
end
