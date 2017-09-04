module SecurityHelper
	CRPT_KEY = ENV['CRPT_KEY'].to_i
	CODE_STRING = ENV['CODE_STRING']
	
	def gen_code
		code_array = []
		rand(3..7).times do 
			code = ""
			rand(10..20).times do 
				letter = CODE_STRING.split('').sample
				code += letter
			end

			code_array << code
		end

		code_array.join('+')
	end

	def encrypt_code(code)
		output = []
		input = code.split('+')
		input.each do |cod|
			tmp = ''
			cod.split('').each do |letter|
				position = (CODE_STRING.split('').index(letter) + CRPT_KEY) % CODE_STRING.length
				tmp += CODE_STRING[position]
			end
			output << tmp
		end

		output.join('-')
	end

	def decrypt_code(code)
		output = []
		input = code.split('-')
		input.each do |cod|
			tmp = ''
			cod.split('').each do |letter|
				position = (CODE_STRING.split('').index(letter) - CRPT_KEY) % CODE_STRING.length
				tmp += CODE_STRING[position]
			end
			output << tmp
		end

		output.join('+')			
	end
end
