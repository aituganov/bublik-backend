extend SecureRandom

class User < ActiveRecord::Base
	has_one :image

	validates :login, :access_token, presence: true, uniqueness: true, length: {maximum: 61}
	validates :login, email_format: { message: 'wrong email format' }
	validates :password, :first_name, :last_name, presence: true, length: {maximum: 50}
	validates :password, length: {minimum: 6}

	before_validation :generate_access_token, on: :create

	def self.get_data(access_token)
		user = User.where(access_token: access_token).take
		user.nil? ? nil : { first_name: user.first_name, last_name: user.last_name, city: user.city, is_deleted: user.is_deleted, anonymous: false }
	end

	def mark_as_deleted
		if self.is_deleted?
			res = false
		else
			res = self.update(is_deleted: true)
		end
		res
	end

	private
	def generate_access_token
		logger.info 'Generate access token...'
		self.access_token = SecureRandom.uuid
		logger.info "Acces token is generated: #{self.access_token}"
	end

end
