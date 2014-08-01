class Company < ActiveRecord::Base
	acts_as_paranoid
	acts_as_taggable_on :tags

	belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'

	validates :owner, :title, presence: true
	validates :title, :slogan, length: {maximum: 50}
	validates :description, length: {maximum: 500}
	validates :rating, inclusion: {in: 0..5}

	def self.get_data(id)
		begin
			company = Company.find(id)
			if company.is_deleted
				res = {is_deleted: company.is_deleted}
			else
				# TODO: tags
				res = {id: company.id, title: company.title, slogan: company.slogan, tags: [], description: company.description, rating: company.rating}
			end
		rescue ActiveRecord::RecordNotFound => e
			res = nil
		end
		res
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
