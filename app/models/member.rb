class Member < ApplicationRecord
	has_many :member_groups, :dependent => :delete_all
	belongs_to :user
	validates :sdcc_member_id, :email, :name, presence: true
	validates_uniqueness_of :sdcc_member_id 


	def needs
		{
			'wensday' => wensday,
			'thursday' => thursday,
			'friday' => friday,
			'saturday' => saturday,
			'sunday' => sunday
		}
	end

	def display_last
		if last_name.nil?
			name.split(' ').last
		else
			last_name
		end
	end

	def active
		!sponsor_id.nil?
	end

	def covered
		Purchase.exists?(:member_id => id)
	end

	def is_part_of(group_id)
		member_groups.any? { |e| e.group_id == group_id }
	end

end
