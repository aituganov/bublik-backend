include AppUtils

class Company < ActiveRecord::Base
	acts_as_paranoid
	acts_as_taggable_on :tags

	belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'

	validates :owner, :title, presence: true
	validates :title, :slogan, length: {maximum: 50}
	validates :description, length: {maximum: 500}
	validates :rating, inclusion: {in: 0..5}

	@@RS_DATA = {FULL: 'full', PRIVILEGES: 'actions', TAGS: 'tags'}

	def self.get_data(id, options={})
		begin
			company = Company.find(id)
			res = company.build_response @@RS_DATA[:FULL], options
		rescue ActiveRecord::RecordNotFound => e
			res = nil
		end
		res
	end

	def self.RS_DATA
		@@RS_DATA
	end

	def build_response(rs_data, options={})
		rs = {}

		if rs_data[@@RS_DATA[:FULL]]
			put_main_data rs
			put_tags_data rs
			put_privileges_data rs, self, options[:access_token]
		elsif rs_data[@@RS_DATA[:PRIVILEGES]]
			put_privileges_data rs, self, options[:access_token]
		elsif rs_data[@@RS_DATA[:TAGS]]
			put_interests_data rs
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

	def is_deleted
		!self.deleted_at.nil?
	end
end
