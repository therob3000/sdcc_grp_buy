class AddActiveBooleanToGroups < ActiveRecord::Migration[5.0]
  def change
  	add_column :members, :active, :boolean, :default => false
  end
end
