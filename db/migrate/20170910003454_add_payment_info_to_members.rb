class AddPaymentInfoToMembers < ActiveRecord::Migration[5.0]
  def change
  	add_column :members, :payment_info, :text
  	add_column :users, :payment_info, :text
  end
end
