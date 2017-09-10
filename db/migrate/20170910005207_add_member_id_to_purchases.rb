class AddMemberIdToPurchases < ActiveRecord::Migration[5.0]
  def change
  	add_column :purchases, :member_id, :integer
  	add_column :purchases, :confirmation_code, :integer
  	add_column :purchases, :covering_id, :integer
  	add_column :purchases, :price, :float
  	add_column :purchases, :notes, :text
  end
end
