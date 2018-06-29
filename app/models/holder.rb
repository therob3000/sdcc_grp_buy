require 'twilio-ruby'

class Holder < ApplicationRecord
  belongs_to :user
  belongs_to :line_day_time_slot

  validates :user_id, uniqueness: {scope: :line_day_time_slot_id, message: 'You cannot be assigned to a group more than once.'}


  def present_name
  	user.name
  end

end
