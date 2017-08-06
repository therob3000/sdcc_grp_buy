class Group < ApplicationRecord
	belongs_to :user
	has_many :member_groups

	validates_uniqueness_of :name
end
