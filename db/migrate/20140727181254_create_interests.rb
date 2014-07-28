class CreateInterests < ActiveRecord::Migration
	def self.up
		create_table :interests do |t|
			t.belongs_to :tag
			t.belongs_to :user
		end
		add_index :interests, [:tag_id, :user_id], :unique => true
	end

	def self.down
		drop_table :interests
		remove_index :interests, [:tag_id, :user_id]
	end
end
