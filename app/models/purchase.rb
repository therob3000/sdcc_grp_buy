class Purchase < ApplicationRecord
	belongs_to :member
	belongs_to :need
	belongs_to :user
end
