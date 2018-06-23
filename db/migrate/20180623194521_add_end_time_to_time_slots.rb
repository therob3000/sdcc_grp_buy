class AddEndTimeToTimeSlots < ActiveRecord::Migration[5.0]
  def change
  	add_column :line_day_time_slots, :end_time, :time
  end
end
