class AddGlobalScopeToChatMessages < ActiveRecord::Migration[5.0]
  def change
  	add_column :chat_messages, :global_scope, :boolean, :default => false
  end
end
