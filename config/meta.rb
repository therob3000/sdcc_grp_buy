class Object

	def meta_class
		class << self
			self
		end
	end


	def the_class
		self
	end


end


p "matt".the_class
p "matt".meta_class
str = "matt"

def str.up
	self.upcase
end

def String.print_me
	'printed'
end


# p str.up

# p String.print_me

# str.send(:define_method :print_me, {self + 'r'})

# p str.print_me


String.send define_method(:charge) { 'dsfsdf'}

p str.charge