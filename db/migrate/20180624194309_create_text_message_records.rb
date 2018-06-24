class CreateTextMessageRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :text_message_records do |t|
    	t.integer :user_id
    	t.integer :originator_id
    	t.text :body
      t.timestamps
    end
  end
end
