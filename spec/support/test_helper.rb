module TestHelper
	def generate_random_string(length)
		(0...length).map { ('a'..'z').to_a[rand(26)] }.join
	end
end