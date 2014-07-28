class Tag < ActiveRecord::Base
	has_many :interest, dependent: :destroy
	has_many :users, through: :interests
	validates :name, presence: true, uniqueness: true, length: {maximum: 100}
end
