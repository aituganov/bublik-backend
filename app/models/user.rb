extend SecureRandom

class User < ActiveRecord::Base
	mount_uploader :avatar, AvatarUploader
	acts_as_paranoid
	acts_as_taggable_on :interests

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

	def get_menu
		{user_id: self.id, menu: %w(companies)}
	end

	def put_main_data(rs)
		rs[:first_name] = self.first_name
		rs[:last_name] = self.last_name
		rs[:is_deleted] = self.is_deleted
		rs[:anonymous] = false
	end

	def put_interests_data(rs)
		rs[:interests] = self.interest_list
	end

	def put_avatar_data(rs)
		rs[:avatar_url] = self.avatar.url
	end

	def interests_add interests
		logger.info "Create interests #{interests.to_json} for user ##{self.id}..."
		self.interest_list.add interests
		self.save!
		logger.info 'Created!'
	end

	def interests_delete interests
		logger.info "Delete interests #{interests.to_json} from user ##{self.id}..."
		self.interest_list.remove interests
		self.save!
		logger.info 'Deleted!'
	end

	def is_deleted
		!self.deleted_at.nil?
	end

	private
	def generate_access_token
		logger.info 'Generate access token...'
		self.access_token = SecureRandom.uuid
		logger.info "Acces token is generated: #{self.access_token}"
	end

end
