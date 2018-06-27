class CreateHolders < ActiveRecord::Migration[5.0]
  def change
    create_table :holders do |t|
      t.references :user, foreign_key: true
      t.integer :number
      t.string :email
      t.integer :line_day_time_slot_id
      t.boolean :active

      t.timestamps
    end
  end
end
