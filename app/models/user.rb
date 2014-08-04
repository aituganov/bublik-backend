include AppUtils
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
	after_update :crop_proccess, :if => :cropping?

	attr_accessor :crop_x, :crop_y, :crop_l

	def cropping?
		!crop_x.blank? && !crop_y.blank? && !crop_l.blank?
	end

	@@RS_DATA = {FULL: 'full', PRIVILEGES: 'privileges', INTERESTS: 'interests', AVATAR: 'avatar', CREATED_COMPANIES: 'created_companies'}

	def self.RS_DATA
		@@RS_DATA
	end

	def build_response(rs_data, options={})
		rs = {}

		if rs_data[@@RS_DATA[:FULL]]
			put_main_data rs
			put_interests_data rs
			put_avatar_data rs
			put_privileges_data rs, self, options[:access_token]
			put_created_company_data rs, options
		elsif rs_data[@@RS_DATA[:PRIVILEGES]]
			put_privileges_data rs, self, options.access_token
		elsif rs_data[@@RS_DATA[:INTERESTS]]
			put_interests_data rs
		elsif rs_data[@@RS_DATA[:AVATAR]]
			put_avatar_data rs
		elsif rs_data[@@RS_DATA[:CREATED_COMPANIES]]
			put_created_company_data rs, options
		end
		rs
	end

	def get_menu
		{user_id: self.id, menu: %w(companies)}
	end

	def put_main_data(rs)
		rs[:id] = self.id
		rs[:first_name] = self.first_name
		rs[:last_name] = self.last_name
		rs[:is_deleted] = self.is_deleted
		rs[:anonymous] = false
	end

	def put_interests_data(rs)
		rs[@@RS_DATA[:INTERESTS]] = self.interest_list
	end

	def put_avatar_data(rs)
		rs[@@RS_DATA[:AVATAR]] = {preview_url: self.avatar.preview.url, fullsize_url: self.avatar.url}
	end

	def put_created_company_data(rs, options)
		rs[@@RS_DATA[:CREATED_COMPANIES]] = []
		get_created_companies(options[:limit] || 6, options[:offset] || 0).each do |company|
			rs[@@RS_DATA[:CREATED_COMPANIES]].push (company.build_response Company.RS_DATA[:FULL], options)
		end
	end

	def get_created_companies(limit, offset)
		logger.info "Finding created companies for user ##{self.id}, limit = #{limit}, offset = #{offset}..."
		res = Company.where(owner_id: self.id).limit(limit).offset(offset)
		logger.info "#{res.count} finded!"
		res
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

	def crop_proccess
		self.avatar.preview.manualcrop(crop_x, crop_y, crop_l)
		self.avatar.recreate_versions!
	end

end
