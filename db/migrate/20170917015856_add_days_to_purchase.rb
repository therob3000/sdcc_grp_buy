class AddDaysToPurchase < ActiveRecord::Migration[5.0]
  def change
  	add_column :purchases, :wensday, :boolean
  	add_column :purchases, :thursday, :boolean
  	add_column :purchases, :friday, :boolean
  	add_column :purchases, :saturday, :boolean
  	add_column :purchases, :sunday, :boolean
  	add_column :purchases, :in_progress, :boolean
  end
end
