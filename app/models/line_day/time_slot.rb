class LineDay::TimeSlot < ApplicationRecord
	has_many :users, through: :time_slots
	has_many :time_slots
end
