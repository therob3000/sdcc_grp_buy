class CreateMemberGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :member_groups do |t|
    	t.integer :member_id
    	t.integer :user_id
    	t.integer :group_id

      t.timestamps
    end
  end
end
