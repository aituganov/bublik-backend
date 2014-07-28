class CreateCompanyTags < ActiveRecord::Migration
	def self.up
		create_table :company_tags do |t|
			t.belongs_to :tag
			t.belongs_to :company
		end
		add_index :company_tags, [:tag_id, :company_id], :unique => true
	end

	def self.down
		drop_table :company_tags
		remove_index :company_tags, [:tag_id, :company_id]
	end
end
