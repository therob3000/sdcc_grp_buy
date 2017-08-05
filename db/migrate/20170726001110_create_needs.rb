class CreateNeeds < ActiveRecord::Migration[5.0]
  def change
    create_table :needs do |t|
    	t.boolean :wensday
    	t.boolean :thursday
    	t.boolean :friday
    	t.boolean :saturday
    	t.boolean :sunday

    	t.boolean :covered

    	t.integer :member_id

      t.timestamps
    end
  end
end
