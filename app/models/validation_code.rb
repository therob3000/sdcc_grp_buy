class ValidationCode < ApplicationRecord
	validates_uniqueness_of :email
  include SecurityHelper

	def self.validate_by_email(email,validation_code)
		code = find_by_email(email)
		(!code.nil?) && (code.code == validation_code)
	end

end
