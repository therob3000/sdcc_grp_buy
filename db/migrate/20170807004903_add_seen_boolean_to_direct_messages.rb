class AddSeenBooleanToDirectMessages < ActiveRecord::Migration[5.0]
  def change
  	add_column :direct_messages, :seen, :boolean, :default => false
  end
end
