class CreateCompanies < ActiveRecord::Migration
	def self.up
		create_table :companies do |t|
			t.integer :owner_id, references: :user
			t.string :title, length: 50
			t.string :slogan, length: 50
			t.text :description, length: 500
			t.float :rating, default: 0
			t.references :image, index: true
			t.datetime :deleted_at

			t.timestamps
		end
		add_index :companies, [:title, :deleted_at]
	end

	def self.down
		remove_index :companies, [:title, :deleted_at]
		drop_table :companies
	end
end
