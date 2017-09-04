# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'faker'

# 5.times do 
# 	Group.create(:name => Faker::Hipster.sentence, :user_id => 2)
# end

# 50.times do 
# 	Group.create(:name => Faker::Hipster.sentence, :user_id => 3)
# end


# 40.times do 
# 	user = User.new(:email => Faker::Internet.safe_email, :name => Faker::Internet.user_name, :avatar_url => Faker::Avatar.image("my-own-slug", "50x50"), :password => 'password')
# 	if !user.save
# 		p user.errors.full_messages
# 	end
# end

# 5.times do 
# 	ChatMessage.create(:group_id => 1, :user_id => 2, :message => Faker::Hacker.say_something_smart)
# end


# 50.times do 
# 	ChatMessage.create(:group_id => 1, :user_id => rand(30), :message => Faker::Hacker.say_something_smart)
# end

# 15.times do 
# 	d = DirectMessage.new(:user_id => 2, :from_user_id => rand(43), :subject => Faker::Hacker.say_something_smart, :body => Faker::Lorem.paragraph(2))
# 	if !d.save
# 		p d.errors.full_messages
# 	end
# end
	CRPT_KEY = ENV['CRPT_KEY'].to_i
	CODE_STRING = ENV['CODE_STRING']


100.times do 
	code_array = []
	rand(3..7).times do 
		code = ""
		rand(10..20).times do 
			letter = CODE_STRING.split('').sample
			code += letter
		end

		code_array << code
	end

	gen_code = code_array.join('+')
	ValidationCode.create(:email => Faker::Internet.safe_email, :code => gen_code)
end
