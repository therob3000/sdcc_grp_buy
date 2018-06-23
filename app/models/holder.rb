class Holder < ApplicationRecord
  belongs_to :user
  belongs_to :line_day_time_slot


  def present_name
  	user.name
  end
end
