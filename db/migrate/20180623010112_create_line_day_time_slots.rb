class CreateLineDayTimeSlots < ActiveRecord::Migration[5.0]
  def change
    create_table :line_day_time_slots do |t|
      t.string :day
      t.text :description
      t.datetime :time
      t.references :line_day, foreign_key: true


      t.timestamps
    end
  end
end
