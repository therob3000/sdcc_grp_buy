class CreateLineDays < ActiveRecord::Migration[5.0]
  def change
    create_table :line_days do |t|
      t.string :day
      t.text :description

      t.timestamps
    end
  end
end
