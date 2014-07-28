class Company < ActiveRecord::Base
	belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
	validates :owner, :title, presence: true
	validates :title, :slogan, length: {maximum: 50}
	validates :description, length: {maximum: 500}
	validates :rating, inclusion: {in: 0..5}

	def self.get_data(id)
		begin
			company = Company.find(id)
			if company.is_deleted
				res = { is_deleted: company.is_deleted }
			else
				# TODO: tags
				res = { id: company.id, title: company.title, slogan: company.slogan, tags: [], description: company.description, rating: company.rating }
			end
		rescue ActiveRecord::RecordNotFound => e
			res = nil
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
end
