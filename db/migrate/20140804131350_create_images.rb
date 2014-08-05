class CreateImages < ActiveRecord::Migration
	def self.up
		create_table :images do |t|
			t.string :file
			t.boolean :current, default: true
			t.references :imageable, polymorphic: true, index: true

			t.timestamps
		end
	end

	def self.down
		drop_table :images
	end
end
