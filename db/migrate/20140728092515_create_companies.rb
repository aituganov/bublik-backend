class CreateCompanies < ActiveRecord::Migration
	def self.up
		create_table :companies do |t|
			t.integer :owner_id, references: :user
			t.string :title, length: 50
			t.string :slogan, length: 50
			t.text :description, length: 500
			t.float :rating, default: 0
			t.references :image, index: true
			t.boolean :is_deleted, default: false

			t.timestamps
		end
	end

	def self.down
		drop_table :companies
	end
end
