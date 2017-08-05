class Purchase < ApplicationRecord
	belongs_to :member, :through => :need
	belongs_to :need
	belongs_to :user
end
