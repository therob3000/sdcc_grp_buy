class AddLastNameToMembers < ActiveRecord::Migration[5.0]
  def change
  	add_column :members, :last_name, :string
  end
end
