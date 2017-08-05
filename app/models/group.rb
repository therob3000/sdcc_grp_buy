class Group < ApplicationRecord
	has_many :member_groups

	validates_uniqueness_of :name
end
