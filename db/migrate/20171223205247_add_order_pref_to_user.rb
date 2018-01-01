class AddOrderPrefToUser < ActiveRecord::Migration[5.0]
  def change
  	add_column :users, :order_prefs, :text
  end
end
