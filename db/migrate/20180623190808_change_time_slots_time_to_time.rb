class ChangeTimeSlotsTimeToTime < ActiveRecord::Migration[5.0]
  def change
  	change_column :line_day_time_slots, :time, :time
  end
end
