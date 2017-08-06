class CreateDirectMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :direct_messages do |t|
    	t.integer :user_id
    	t.integer :from_user_id

    	t.string :subject
    	t.text :body

      t.timestamps
    end
  end
end
