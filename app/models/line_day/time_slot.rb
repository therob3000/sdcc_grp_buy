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

		def present_people
			holders.includes(:user).map { |e| e.user.name }.join(',')
		end

		def present_info
			{
				time: present_time,
				people: present_people,
				id: id
			}
		end

		def send_text_message_to_grp
			
		end

end
