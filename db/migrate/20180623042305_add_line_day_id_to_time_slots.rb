class AddLineDayIdToTimeSlots < ActiveRecord::Migration[5.0]
  def change
  	add_column :line_day_time_slots, :line_day_id, :integer
  end
end
