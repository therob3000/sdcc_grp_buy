class AddCheckedInToMembers < ActiveRecord::Migration[5.0]
  def change
  	add_column :members, :checked_in, :boolean, :default => false
  end
end
