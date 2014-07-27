class CreateTags < ActiveRecord::Migration
	def self.up
		create_table :tags do |t|
			t.string :name, length: 100

			t.timestamps
		end
		add_index :tags, :name, :unique => true
	end

	def self.down
		drop_table :tags
		remove_index :tags, :name
	end
end