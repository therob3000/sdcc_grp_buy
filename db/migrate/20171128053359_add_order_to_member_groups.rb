class AddOrderToMemberGroups < ActiveRecord::Migration[5.0]
  def change
  	add_column :member_groups, :order, :integer, :default => 0
  end
end
