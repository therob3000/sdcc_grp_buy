class Member < ApplicationRecord
	has_many :member_groups, :dependent => :delete_all
	belongs_to :user
	validates :sdcc_member_id, :email, :last_name, presence: true
	validates_uniqueness_of :sdcc_member_id 
	has_many :purchases
	validate :user_is_admin, :on => :create


	def needs
		# output = {
		# 	'wensday' => (days_bought["wensday"] ? false : wensday),
		# 	'thursday' => (days_bought["thursday"] ? false : thursday),
		# 	'friday' => (days_bought["friday"] ? false : friday),
		# 	'saturday' => (days_bought["saturday"] ? false : saturday),
		# 	'sunday' => (days_bought["sunday"] ? false : sunday)
		# }
		output = {
			'wensday' => wensday,
			'thursday' => thursday,
			'friday' => friday,
			'saturday' => saturday,
			'sunday' => sunday
		}

		# out2 = output.select do |k,v| 
		# 	v == true 
		# end

		# new_out = {}

		# out2.map do |k,v|
		# 	new_out[k] = days_bought[k]
		# end

		# new_out

		output

	end

	def user_is_admin
		if !user.is_admin?
			errors.add(:user_id, "Only Admins may register members.")
		end
	end

	def min_days
		output = {
			'wensday' => min_wensday,
			'thursday' => min_thursday,
			'friday' => min_friday,
			'saturday' => min_saturday,
			'sunday' => min_sunday			
		}

		if output.values.any? { |e| e == true }
			output
		else
			nil
		end
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

	def contact_info(viewing_user)
    if viewing_user.is_valid?
      "#{name} / #{email}"
    else
      "---protected---"
    end
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
		# return true if days_bought and days_needed the same
		# Purchase.exists?(:member_id => id)
		# needs.values.all? { |e| !e }
		output = true
		needs.each do |k,v|
			if days_bought[k] != v
				output = false
			end
		end

		output
	end

	def has_purchase
		Purchase.exists?(:member_id => id)
	end

	def days_left
		# needs - days_bought
		out = {} 
		needs.each do |k,v|
			if v
				out[k] = days_bought[k]
			end
		end

		out
	end

	def still_needs(day)
		days_left[day]
	end

	def full_covered
		# needs.values.all? { |e| e }
		out = {}
		needs.map do |k,v| 
			if v == true 
				out[k] = days_bought[k]
			end
		end

		out.values.all? { |e| e }
	end

	def is_part_of(group_id)
		member_groups.any? { |e| e.group_id == group_id }
	end

end
