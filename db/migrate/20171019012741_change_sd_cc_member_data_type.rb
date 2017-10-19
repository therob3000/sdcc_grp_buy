class ChangeSdCcMemberDataType < ActiveRecord::Migration[5.0]
  def change
  	change_column :members, :sdcc_member_id, :string
  end
end
