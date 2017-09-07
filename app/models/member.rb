class Member < ApplicationRecord
	has_many :member_groups
	# has_many :needs
	belongs_to :user
	# validates :sdcc_member_id, :email, :name, :phone, presence: true
	validates_uniqueness_of :sdcc_member_id 
	# user_id: integer, sdcc_member_id: integer, name: string, phone: string, email: string, covered: boolean,

	# def covered?
		# needs.all? { |e| e.covered? }

	# end

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
