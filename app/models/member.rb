class Member < ApplicationRecord
	has_many :member_groups, :dependent => :delete_all
	belongs_to :user
	validates :sdcc_member_id, :email, :name, presence: true
	validates_uniqueness_of :sdcc_member_id 
	has_many :purchases


	def needs
		output = {
			'wensday' => (days_bought["wensday"] ? false : wensday),
			'thursday' => (days_bought["thursday"] ? false : thursday),
			'friday' => (days_bought["friday"] ? false : friday),
			'saturday' => (days_bought["saturday"] ? false : saturday),
			'sunday' => (days_bought["sunday"] ? false : sunday)
		}
	end

	def days_bought
		tally = {
			'wensday' => false,
			'thursday' => false,
			'friday' => false,
			'saturday' => false,
			'sunday' => false
		}

		purchases.each do |pur|
			["wensday","thursday","friday","saturday","sunday"].each do |day|
				if pur[day]
					tally[day] = true
				end
			end
		end

		tally
	end

	def checked_in
		checked_in_date == Date.today
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

	def full_covered
		needs.values.all? { |e| !e }
	end

	def is_part_of(group_id)
		member_groups.any? { |e| e.group_id == group_id }
	end

end
