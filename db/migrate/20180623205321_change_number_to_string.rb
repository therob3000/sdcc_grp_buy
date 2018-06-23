class ChangeNumberToString < ActiveRecord::Migration[5.0]
  def change
  	change_column :holders, :number, :string
  end
end
