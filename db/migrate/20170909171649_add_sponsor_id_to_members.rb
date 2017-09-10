class AddSponsorIdToMembers < ActiveRecord::Migration[5.0]
  def change
  	add_column :members, :sponsor_id, :integer
  end
end
