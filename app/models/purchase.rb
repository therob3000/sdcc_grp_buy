class Purchase < ApplicationRecord
	belongs_to :member
	belongs_to :user

	def days_string
		output = []
		days = [
			{:day => wensday, :string => "wensday" }, 
			{:day => thursday, :string => "thursday" }, 
			{:day => friday, :string => "friday" }, 
			{:day => saturday, :string => "saturday" }, 
			{:day => sunday, :string => "sunday" }
		]
		days.each do |day|
			if day[:day]
				output << day[:string]
			end
		end

		output.join(', ')
	end

	def benefactor_name
		if covering_id
			if Member.exists?(covering_id)
				member = Member.find(covering_id)
				m_name = "#{member.name} #{member.last_name}"
			else
				m_name = 'user not found'
			end
		else
			member = current_user
			m_name = "#{member.name}"
		end

		m_name
	end

	def benefactor_email
		if covering_id
			if Member.exists?(covering_id)
				member = Member.find(covering_id)
				mail = member.email
			else
				mail = ''
			end
		else
			member = User.find(user_id)
			mail = member.email
		end

		mail
	end

end
