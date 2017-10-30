class AddEmailToPurchases < ActiveRecord::Migration[5.0]
  def change
  	add_column :purchases, :buyer_email, :string
  end
end
