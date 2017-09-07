class AddDaysToMembers < ActiveRecord::Migration[5.0]
  def change
  	add_column :members, :wensday, :boolean
  	add_column :members, :thursday, :boolean
  	add_column :members, :friday, :boolean
  	add_column :members, :saturday, :boolean
  	add_column :members, :sunday, :boolean
  	add_column :members, :in_progress, :boolean
  end
end
