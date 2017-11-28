class AddMinDaysToMember < ActiveRecord::Migration[5.0]
  def change
  	add_column :members, :min_wensday, :boolean, :default => false
		add_column :members, :min_thursday, :boolean, :default => false
		add_column :members, :min_friday, :boolean, :default => false
		add_column :members, :min_saturday, :boolean, :default => false
		add_column :members, :min_sunday, :boolean, :default => false
  end
end
