include AppUtils
extend SecureRandom
include SocialAdapter

class User < ActiveRecord::Base
	acts_as_paranoid
	acts_as_taggable_on :interests
	acts_as_follower
	acts_as_followable
	has_many :images, as: :imageable, :dependent => :destroy

	validates :login, :access_token, presence: true, uniqueness: true, length: {maximum: 61}
	validates :login, email_format: { message: 'wrong email format' }
	validates :password, :first_name, :last_name, presence: true, length: {maximum: 50}
	validates :password, length: {minimum: 6}

	before_validation :generate_access_token, on: :create

	@@RS_DATA = {
			FULL: :full,
			CURRENT_USER: :current,
			PRIVILEGES: :privileges,
			INTERESTS: :interests,
			AVATAR: :avatar,
			AVATARS: :avatars,
			CREATED_COMPANIES: :created_companies,
			SOCIAL: :social,
			FOLLOWED_USERS: :followed_users,
			FOLLOWED_COMPANIES: :followed_companies,
			FOLLOWERS: :followers
	}

	# Public methods

	def full_name
		"#{self.first_name} #{self.last_name}"
	end

	def current_user
		{user: {id: self.id, full_name: self.full_name, avatar_preview_url: self.get_current_image_preview_url }, menu_items: %w(companies)}
	end

	def get_current_image
		Image.get_current(self)
	end

	def get_current_image_preview_url
		current = self.get_current_image
		!current.nil? ? current.file.preview.url : nil
	end

	def is_deleted
		!self.deleted_at.nil?
	end

	def self.RS_DATA
		@@RS_DATA
	end

	# Build response

	def build_response(rs_data, options={})
		rs = {}
		requester = options[:requester]

		if rs_data[@@RS_DATA[:FULL]]
			put_main_data rs
			put_interests_data rs
			put_current_avatar_data rs, requester
			put_privileges_data rs, self, requester
			put_created_company_data rs, options
			put_social_data rs, requester, options
		elsif rs_data[@@RS_DATA[:PRIVILEGES]]
			put_privileges_data rs, self, requester
		elsif rs_data[@@RS_DATA[:INTERESTS]]
			put_interests_data rs
		elsif rs_data[@@RS_DATA[:AVATARS]]
			put_all_avatars_data rs, requester
		elsif rs_data[@@RS_DATA[:AVATAR]]
			put_current_avatar_data rs, requester
		elsif rs_data[@@RS_DATA[:CREATED_COMPANIES]]
			put_created_company_data rs, options
		elsif rs_data[@@RS_DATA[:FOLLOWED_USERS]]
			rs = put_followed_users_data options
		elsif rs_data[@@RS_DATA[:FOLLOWED_COMPANIES]]
			rs = put_followed_companies_data options
		elsif rs_data[@@RS_DATA[:FOLLOWERS]]
			rs = put_followers_data options
		elsif rs_data[@@RS_DATA[:CURRENT_USER]]
			rs = get_current_info;
		end
		rs
	end

	def put_main_data(rs)
		rs[:id] = self.id
		rs[:full_name] = self.full_name
		rs[:first_name] = self.first_name
		rs[:last_name] = self.last_name
		rs[:is_deleted] = self.is_deleted
		rs[:anonymous] = false
	end

	def get_current_info
		{info: {id: self.id, full_name: self.full_name, avatar_preview_url: self.get_current_image_preview_url}, menu_items: %w(selfpage companies)}
	end

	# Avatars response block

	def put_all_avatars_data(rs, requester)
		rs[@@RS_DATA[:AVATARS]] = []
		self.images.each { |i| rs[@@RS_DATA[:AVATARS]].push(i.build_response requester) }
	end

	def put_current_avatar_data(rs, requester)
		current = get_current_image
		rs[@@RS_DATA[:AVATAR]] = current.build_response requester unless current.nil?
	end

	# Social block
	def put_social_data(rs, requester, options)
		rs[@@RS_DATA[:SOCIAL]] = {}

		put_social_actions rs[@@RS_DATA[:SOCIAL]], self, requester
		rs[@@RS_DATA[:SOCIAL]][@@RS_DATA[:FOLLOWED_USERS]] = put_followed_users_data options
		rs[@@RS_DATA[:SOCIAL]][@@RS_DATA[:FOLLOWED_COMPANIES]] = put_followed_companies_data options
		rs[@@RS_DATA[:SOCIAL]][@@RS_DATA[:FOLLOWERS]] = put_followers_data options
	end

	# Created companies response block

	def put_created_company_data(rs, options)
		rs[@@RS_DATA[:CREATED_COMPANIES]] = []
		get_created_companies(options[:limit], options[:offset]).each do |company|
			rs[@@RS_DATA[:CREATED_COMPANIES]].push (company.build_response({Company.RS_DATA[:FULL] => true}, options))
		end
	end

	def get_created_companies(limit, offset)
		limit ||= AppSettings.limit_preview
		offset ||= AppSettings.offset_default
		logger.info "Finding created companies for user ##{self.id}, limit = #{limit}, offset = #{offset}..."
		res = Company.where(owner_id: self.id).limit(limit).offset(offset)
		logger.info "#{res.count} finded!"
		res
	end

	# Socialization response block

	def get_follow_data
		{id: self.id, title: self.full_name, preview_url: self.get_current_image_preview_url}
	end

	def put_followed_users_data(options)
		data = []
		get_followed_users(options[:limit], options[:offset]).each do |user|
			data.push user.get_follow_data
		end
		data
	end

	def get_followed_users(limit, offset)
		logger.info "Finding followed users for user ##{self.id}, limit = #{limit}, offset = #{offset}..."
		res = get_followed(self.class, self, limit, offset)
		logger.info "#{res.count} finded!"
		res
	end

	def put_followed_companies_data(options)
		data = []
		get_followed_companies(options[:limit], options[:offset]).each do |company|
			data.push company.get_follow_data
		end
		data
	end

	def get_followed_companies(limit, offset)
		logger.info "Finding followed companies for user ##{self.id}, limit = #{limit}, offset = #{offset}..."
		res = get_followed(Company, self, limit, offset)
		logger.info "#{res.count} finded!"
		res
	end

	def put_followers_data(options)
		data = []
		get_follower_users(options[:limit], options[:offset]).each do |company|
			data.push company.get_follow_data
		end
		data
	end

	def get_follower_users(limit, offset)
		logger.info "Finding followers for user ##{self.id}, limit = #{limit}, offset = #{offset}..."
		res = get_followers(self.class, self, limit, offset)
		logger.info "#{res.count} finded!"
		res
	end

	# Interests response block

	def put_interests_data(rs)
		rs[@@RS_DATA[:INTERESTS]] = self.interest_list
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

	private

	def generate_access_token
		logger.info 'Generate access token...'
		self.access_token = SecureRandom.uuid
		logger.info "Acces token is generated: #{self.access_token}"
	end

end
