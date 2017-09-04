class AddValidatedBooleanToUsers < ActiveRecord::Migration[5.0]
  def change
  	add_column :users, :validation_code, :string
  	add_column :users, :is_admin, :boolean, :default => false
  end
end
