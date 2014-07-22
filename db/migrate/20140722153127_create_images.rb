class CreateImages < ActiveRecord::Migration
	def self.up
		create_table :images do |t|
			t.string :preview_url
			t.string :fullsize_url

			t.timestamps
		end
	end
	def self.down
		drop_table :images
	end
end
