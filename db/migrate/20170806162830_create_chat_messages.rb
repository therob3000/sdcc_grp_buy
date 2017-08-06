class CreateChatMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :chat_messages do |t|
    	t.string :message
    	t.integer :group_id
    	t.integer :user_id

      t.timestamps
    end
  end
end
