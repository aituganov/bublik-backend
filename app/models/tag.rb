class Tag < ActiveRecord::Base
	has_many :interest, dependent: :destroy
	has_many :users, through: :interests

	has_many :company_tag, dependent: :destroy
	has_many :companies, through: :company_tag
	
	validates :name, presence: true, uniqueness: true, length: {maximum: 100}
end
