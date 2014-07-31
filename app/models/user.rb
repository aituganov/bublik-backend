extend SecureRandom

class User < ActiveRecord::Base
	mount_uploader :avatar, AvatarUploader

	has_many :interests, dependent: :destroy
	has_many :tags, through: :interests

	validates :login, :access_token, presence: true, uniqueness: true, length: {maximum: 61}
	validates :login, email_format: { message: 'wrong email format' }
	validates :password, :first_name, :last_name, presence: true, length: {maximum: 50}
	validates :password, length: {minimum: 6}

	before_validation :generate_access_token, on: :create

	@@RS_DATA = {:FULL => 'full', :INTERESTS => 'interests', :AVATAR => 'avatar'}

	def self.RS_DATA
		@@RS_DATA
	end

	def get_data(rs_data)
		rs = {}
		if rs_data[@@RS_DATA[:FULL]]
			put_main_data rs
			put_interests_data rs
			put_avatar_data rs
		elsif rs_data[@@RS_DATA[:INTERESTS]]
			put_interests_data rs
		elsif rs_data[@@RS_DATA[:AVATAR]]
			put_avatar_data rs
		end
		rs
	end

	def put_main_data(rs)
		rs[:first_name] = self.first_name
		rs[:last_name] = self.last_name
		rs[:is_deleted] = self.is_deleted
		rs[:anonymous] = false
	end

	def put_interests_data(rs)
		rs[:interests] = self.tags.map {|i| i.name}
	end

	def put_avatar_data(rs)
		rs[:avatar_url] = self.avatar.url
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
