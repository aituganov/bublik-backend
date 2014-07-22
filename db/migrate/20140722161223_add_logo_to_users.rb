class AddLogoToUsers < ActiveRecord::Migration
  def self.up
    add_reference :users, :logo, index: true
  end
	def self.down
		remove_column :users, :logo_id
	end
end
