class CreateUsers < ActiveRecord::Migration
	def self.up
		create_table :users do |t|
			t.string :login
			t.string :password
			t.string :access_token
			t.string :first_name
			t.string :last_name
			t.string :city
			t.datetime :deleted_at

			t.timestamps
		end
		add_index :users, [:login, :deleted_at]
	end

	def self.down
		remove_index :users, [:login, :deleted_at]
		drop_table :users
	end
end
