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

	def benefactor_name(current_user=nil)
		if covering_id
			if Member.exists?(covering_id)
				member = Member.find(covering_id)
				m_name = "#{member.name} #{member.last_name}"
			else
				m_name = 'user not found'
			end
		elsif buyer_email
			m_name = buyer_email
		else
			member = current_user
			m_name = "#{member.try(:name)}"
		end

		m_name
	end

	def benefactor_email(current_user=nil)
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

	def send_out_confirmation(current_user,env=nil)
		# find the purchase
		purchasing_member_first_name = benefactor_name(current_user)
		email_to = member.email
		if env == 'dev'
			email_to = 'laomatt1@gmail.com'
		end
		obj = {
        email: email_to, 
        member: member,
        purchase: nil,
        purchasing_member_notes: notes,
        purchasing_member_first_name: benefactor_name(current_user),
        purchasing_member_name: benefactor_name(current_user),
        add_notes: ""
      }


		MyMailer.send_confirmation(obj, "CONGRATULATIONS!  #{purchasing_member_first_name} has covered you for SDCC 2018!!").deliver
	end

end
