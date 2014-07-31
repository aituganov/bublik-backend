class Company < ActiveRecord::Base
	has_many :company_tags, dependent: :destroy
	has_many :tags, through: :company_tags

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

	def set_tags tags
		logger.info "Create tags for company ##{self.id}, tags: #{tags.to_json}"
		errors = []
		tags.each do |id|
			tag = Tag.where(id: id).take
			if tag.nil?
				errors.push("Tag ##{id} not found")
			else
				begin
					self.company_tags.create(tag_id: id)
				rescue Exception => e
					errors.push(e.class == ActiveRecord::RecordNotUnique ? "Tag ##{id} already registered" : e.message)
				end
			end
		end
		errors
	end

	def mark_as_deleted
		if self.is_deleted?
			res = false
		else
			res = self.update(is_deleted: true)
		end
		res
	end
end
