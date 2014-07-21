require 'spec_helper'

describe User do
	context 'check validators' do
		it 'should require a login' do
			FactoryGirl.build(:user, login: '').should_not be_valid
			FactoryGirl.build(:user, login: '').should have(2).error_on(:login)
		end

		it 'should require a password' do
			FactoryGirl.build(:user, password: '').should_not be_valid
			FactoryGirl.build(:user, password: '').should have(1).error_on(:password)
		end

		it 'should require a first_name' do
			FactoryGirl.build(:user, first_name: '').should_not be_valid
			FactoryGirl.build(:user, first_name: '').should have(1).error_on(:first_name)
		end

		it 'should require a last_name' do
			FactoryGirl.build(:user, last_name: '').should_not be_valid
			FactoryGirl.build(:user, last_name: '').should have(1).error_on(:last_name)
		end
	end

	context 'create user' do
		it 'create user and check access token' do
			FactoryGirl.create(:user).should be_valid
			User.first.access_token.should_not be_empty
			FactoryGirl.build(:user).should_not be_valid
		end

		it 'check dont duplicate login' do
			FactoryGirl.create(:user).should be_valid
			FactoryGirl.build(:user).should have(1).error_on(:login)
		end
	end

	context 'update user' do
		it 'user should be updated' do
			last_name = 'Changed last name'
			FactoryGirl.create(:user).should be_valid
			user = User.first
			user.last_name = last_name
			user.save
			user.last_name.should eq last_name
		end

		context 'delete user' do
			it 'user should be deleted' do
				FactoryGirl.create(:user).should be_valid
				User.first.destroy
				User.first.should be_nil
			end
		end
	end

end
