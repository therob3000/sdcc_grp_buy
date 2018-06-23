# module LineDay
#   def self.table_name_prefix
#     'line_day_'
#   end
# end


class LineDay < ApplicationRecord
	has_many :users, through: :line_day_time_slots
	has_many :time_slots
end