class CreateEmails < ActiveRecord::Migration[5.0]
  def change
    create_table :emails do |t|
    	t.string :to
    	t.string :from
    	t.string :cc
    	t.text :body
    	t.string :type
      t.timestamps
    end
  end
end
