include AppUtils

class Company < ActiveRecord::Base
	acts_as_paranoid
	acts_as_taggable_on :tags
	acts_as_followable

	has_many :images, as: :imageable, :dependent => :destroy

	belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'

	validates :owner, :title, presence: true
	validates :title, :slogan, length: {maximum: 50}
	validates :description, length: {maximum: 500}
	validates :rating, inclusion: {in: 0..5}

	@@RS_DATA = {
			FULL: :full,
			PRIVILEGES: :actions,
			TAGS: :tags,
			LOGOTYPES: :logotypes,
			LOGOTYPE: :logotype,
			FOLLOWERS: :followers
	}

	# Public methods

	def get_current_image
		Image.get_current(self)
	end

	def get_current_image_preview_url
		current = get_current_image
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
			put_tags_data rs
			put_privileges_data rs, self, requester
			put_current_logotype_data rs, requester
			put_social_data rs, self, requester
			rs[@@RS_DATA[:FOLLOWERS]] = get_followers_data options
		elsif rs_data[@@RS_DATA[:PRIVILEGES]]
			put_privileges_data rs, self, requester
		elsif rs_data[@@RS_DATA[:TAGS]]
			put_tags_data rs
		elsif rs_data[@@RS_DATA[:LOGOTYPES]]
			put_all_logotypes_data rs, requester
		elsif rs_data[@@RS_DATA[:FOLLOWERS]]
			rs = get_followers_data options
		end
		rs
	end

	def put_main_data(rs)
		rs[:id] = self.id
		rs[:title] = self.title
		rs[:slogan] = self.slogan
		rs[:rating] = self.rating
		rs[:description] = self.description
		rs[:is_deleted] = self.is_deleted
	end

	# Logo's response block

	def put_all_logotypes_data(rs, requester)
		rs[@@RS_DATA[:LOGOTYPES]] = []
		self.images.each { |i| rs[@@RS_DATA[:LOGOTYPES]].push(i.build_response requester) }
	end

	def put_current_logotype_data(rs, requester)
		current = get_current_image
		rs[@@RS_DATA[:LOGOTYPE]] = current.build_response requester unless current.nil?
	end

	# Tags response block

	def put_tags_data(rs)
		rs[@@RS_DATA[:TAGS]] = self.tag_list
	end

	def tags_add tags
		logger.info "Create tags #{tags.to_json} for company ##{self.id}..."
		self.tag_list.add tags
		self.save!
		logger.info 'Created!'
	end

	def tags_delete tags
		logger.info "Delete tags #{tags.to_json} from company ##{self.id}..."
		self.tag_list.remove tags
		self.save!
		logger.info 'Deleted!'
	end

	# Socialization response block

	def get_follow_data
		{id: self.id, title: self.title, preview_url: self.get_current_image_preview_url}
	end

	def get_followers_data(options)
		data = []
		get_follower_users(options[:limit], options[:offset]).each do |user|
			data.push user.get_follow_data
		end
		data
	end

	def get_follower_users(limit, offset)
		logger.info "Finding followers for company ##{self.id}, limit = #{limit}, offset = #{offset}..."
		res = get_followers(User, self, limit, offset)
		logger.info "#{res.count} finded!"
		res
	end

end
