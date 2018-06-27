class LineDay::TimeSlot < ApplicationRecord
		has_many :holders, :foreign_key => :line_day_time_slot_id, :dependent => :destroy
		belongs_to :line_day
		default_scope { order(:time => :asc) }
		before_save :cover_end_time


		def present_time
			"#{time.strftime("%l:%M %p")} - #{end_time.try('strftime',"%l:%M %p")}"			
		end

		def cover_end_time
			if end_time.nil? || end_time == ''
				end_time = time + 1.hour
			end
		end

		def present_people(current_user_id)
			people = []
			@has_current = false
			holders.includes(:user).each { |e| 
				if e.user_id == current_user_id
					@has_current = true
				end
				people << e.user.attributes.slice("name","id")
			}
			people
		end

		def present_info(current_user_id)
			people_array = present_people(current_user_id)
			people = people_array.map{ |e| e["name"] }.join(',')

			{
				time: present_time,
				people: people,
				people_hash: people_array,
				notes: description,
				id: id,
				has_current: @has_current
			}
		end

		def has_current_user
			
		end

		def send_text_message_to_grp
			
		end

end
