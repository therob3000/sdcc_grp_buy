class AddCheckedInDateToMembers < ActiveRecord::Migration[5.0]
  def change
  	add_column :members, :checked_in_date, :date
  	remove_column :members, :checked_in
  end
end
