class CreateMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :members do |t|
    	t.integer :user_id
    	t.integer :sdcc_member_id
    	t.string :name
    	t.string :phone
    	t.string :email

    	t.boolean :covered, :default => false

      t.timestamps
    end
  end
end
