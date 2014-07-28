class CompanyTag < ActiveRecord::Base
	belongs_to :company
	belongs_to :tag
end