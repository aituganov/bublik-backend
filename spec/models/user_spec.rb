require 'spec_helper'

describe User do
	context 'check validators' do
		it 'should require a login' do
			FactoryGirl.build(:user, login: '').should_not be_valid
			FactoryGirl.build(:user, login: '').should have(2).error_on(:login)
		end

		it 'login should error if more then 61' do
			long_login = (0...30).map { ('a'..'z').to_a[rand(26)] }.join + '@' + (0...27).map { ('a'..'z').to_a[rand(26)] }.join + '.com'
			FactoryGirl.build(:user, login: long_login).should_not be_valid
			FactoryGirl.build(:user, login: long_login).should have(1).error_on(:login)
		end

		it 'should ok if login less or equal then 61' do
			correct_login = (0...30).map { ('a'..'z').to_a[rand(26)] }.join + '@' + (0...26).map { ('a'..'z').to_a[rand(26)] }.join + '.com'
			FactoryGirl.build(:user, login: correct_login).should be_valid
		end

		it 'should require a password' do
			FactoryGirl.build(:user, password: '').should_not be_valid
			FactoryGirl.build(:user, password: '').should have(1).error_on(:password)
		end

		it 'password should error if more then 50' do
			long_password = (0...51).map { ('a'..'z').to_a[rand(26)] }.join
			FactoryGirl.build(:user, password: long_password).should_not be_valid
			FactoryGirl.build(:user, password: long_password).should have(1).error_on(:password)
		end

		it 'password should ok if less or equal then 50' do
			correct_password = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
			FactoryGirl.build(:user, password: correct_password).should be_valid
		end

		it 'should require a first_name' do
			FactoryGirl.build(:user, first_name: '').should_not be_valid
			FactoryGirl.build(:user, first_name: '').should have(1).error_on(:first_name)
		end

		it 'first_name should error if more then 50' do
			long_first_name = (0...51).map { ('a'..'z').to_a[rand(26)] }.join
			FactoryGirl.build(:user, first_name: long_first_name).should_not be_valid
			FactoryGirl.build(:user, first_name: long_first_name).should have(1).error_on(:first_name)
		end

		it 'first_name should ok if less or equal then 50' do
			correct_first_name = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
			FactoryGirl.build(:user, first_name: correct_first_name).should be_valid
		end

		it 'should require a last_name' do
			FactoryGirl.build(:user, last_name: '').should_not be_valid
			FactoryGirl.build(:user, last_name: '').should have(1).error_on(:last_name)
		end
	end

	it 'last_name should error if more then 50' do
		long_last_name = (0...51).map { ('a'..'z').to_a[rand(26)] }.join
		FactoryGirl.build(:user, last_name: long_last_name).should_not be_valid
		FactoryGirl.build(:user, last_name: long_last_name).should have(1).error_on(:last_name)
	end

	it 'last_name should ok if less or equal then 50' do
		correct_last_name = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
		FactoryGirl.build(:user, last_name: correct_last_name).should be_valid
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
