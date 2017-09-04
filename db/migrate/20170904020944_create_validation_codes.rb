class CreateValidationCodes < ActiveRecord::Migration[5.0]
  def change
    create_table :validation_codes do |t|
    	t.string :email
    	t.string :code
      t.timestamps
    end
  end
end
