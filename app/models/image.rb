class Image < ActiveRecord::Base
	validates :preview_url, presence: true
end
