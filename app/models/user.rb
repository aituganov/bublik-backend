extend SecureRandom

class User < ActiveRecord::Base
	has_many :interests, dependent: :destroy
	has_many :tags, through: :interests

	validates :login, :access_token, presence: true, uniqueness: true, length: {maximum: 61}
	validates :login, email_format: { message: 'wrong email format' }
	validates :password, :first_name, :last_name, presence: true, length: {maximum: 50}
	validates :password, length: {minimum: 6}

	before_validation :generate_access_token, on: :create

	def self.get_data(access_token)
		user = User.where(access_token: access_token).take
		if user.nil?
			res = nil
		else
			interests = user.interests.map {|i| i.name}
			res = { first_name: user.first_name, last_name: user.last_name, city: user.city, interests: interests, is_deleted: user.is_deleted, anonymous: false }
		end
		res
	end

	def mark_as_deleted
		if self.is_deleted?
			res = false
		else
			res = self.update(is_deleted: true)
		end
		res
	end

	def set_interests tags
		logger.info "Create interests for user ##{self.id}, tags: #{tags.to_json}"
		errors = []
		tags.each do |id|
			tag = Tag.where(id: id).take
			if tag.nil?
				errors.push("Tag ##{id} not found")
			else
				begin
					self.interests.create(tag_id: id)
				rescue Exception => e
					errors.push(e.class == ActiveRecord::RecordNotUnique ? "Interest ##{id} already registered" : e.message)
				end
			end
		end
		errors
	end

	private
	def generate_access_token
		logger.info 'Generate access token...'
		self.access_token = SecureRandom.uuid
		logger.info "Acces token is generated: #{self.access_token}"
	end

end
