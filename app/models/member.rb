class Member < ApplicationRecord
	has_many :member_groups
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

end
