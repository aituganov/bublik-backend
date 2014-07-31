require 'spec_helper'

describe User do
	context 'check validators' do
		it 'should require a login' do
			FactoryGirl.build(:user, login: '').should_not be_valid
			FactoryGirl.build(:user, login: '').should have(2).error_on(:login)
		end

		it 'login should error if more then 61' do
			long_login = generate_random_string(30) + '@' + generate_random_string(27) + '.com'
			FactoryGirl.build(:user, login: long_login).should_not be_valid
			FactoryGirl.build(:user, login: long_login).should have(1).error_on(:login)
		end

		it 'should ok if login less or equal then 61' do
			correct_login = generate_random_string(30) + '@' + generate_random_string(26) + '.com'
			FactoryGirl.build(:user, login: correct_login).should be_valid
		end

		it 'should require a password and password dont less 6' do
			FactoryGirl.build(:user, password: '').should_not be_valid
			FactoryGirl.build(:user, password: '').should have(2).error_on(:password)
		end

		it 'password should error if less then 6' do
			short_password = generate_random_string 5
			FactoryGirl.build(:user, password: short_password).should_not be_valid
			FactoryGirl.build(:user, password: short_password).should have(1).error_on(:password)
		end

		it 'password should error if more then 50' do
			long_password = generate_random_string 51
			FactoryGirl.build(:user, password: long_password).should_not be_valid
			FactoryGirl.build(:user, password: long_password).should have(1).error_on(:password)
		end

		it 'password should ok if less or equal then 50' do
			correct_password = generate_random_string 6
			FactoryGirl.build(:user, password: correct_password).should be_valid

			correct_password = generate_random_string 50
			FactoryGirl.build(:user, password: correct_password).should be_valid
		end

		it 'should require a first_name' do
			FactoryGirl.build(:user, first_name: '').should_not be_valid
			FactoryGirl.build(:user, first_name: '').should have(1).error_on(:first_name)
		end

		it 'first_name should error if more then 50' do
			long_first_name = generate_random_string 51
			FactoryGirl.build(:user, first_name: long_first_name).should_not be_valid
			FactoryGirl.build(:user, first_name: long_first_name).should have(1).error_on(:first_name)
		end

		it 'first_name should ok if less or equal then 50' do
			correct_first_name = generate_random_string 50
			FactoryGirl.build(:user, first_name: correct_first_name).should be_valid
		end

		it 'should require a last_name' do
			FactoryGirl.build(:user, last_name: '').should_not be_valid
			FactoryGirl.build(:user, last_name: '').should have(1).error_on(:last_name)
		end
	end

	it 'last_name should error if more then 50' do
		long_last_name = generate_random_string 51
		FactoryGirl.build(:user, last_name: long_last_name).should_not be_valid
		FactoryGirl.build(:user, last_name: long_last_name).should have(1).error_on(:last_name)
	end

	it 'last_name should ok if less or equal then 50' do
		correct_last_name = generate_random_string 50
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
		before (:each) do
			@user = FactoryGirl.create(:user)
			@user.should be_valid
		end

		it 'user should be updated' do
			last_name = 'Changed last name'
			@user.last_name = last_name
			@user.save
			@user.last_name.should eq last_name
		end

		it 'add new interests to the user' do
			@user.interest_list.add(['first', 'second'])
			@user.save
			@user.interest_list.should have(2).item
			@user.interests.should have(2).item
			Tag.all.should have(2).item
		end

		it 'check interests uniq' do
			@user.interest_list.add(['first', 'first'])
			@user.save
			@user.interest_list.should have(1).item
			@user.interests.should have(1).item
			Tag.all.should have(1).item
		end

		it 'add existed interest to user' do
			@user.interest_list.add(['first', 'second'])
			@user.save
			@user.interest_list.should have(2).item
			@user.interests.should have(2).item

			second_user = FactoryGirl.create(:user_second)
			second_user.should be_valid
			second_user.interest_list.add(['second', 'third'])
			second_user.save
			second_user.interest_list.should have(2).item
			second_user.interests.should have(2).item

			Tag.all.should have(3).item
		end

		it 'check interests remove' do
			@user.interest_list.add(['first', 'second'])
			@user.save
			@user.interest_list.should have(2).item
			@user.interests.should have(2).item
			Tag.all.should have(2).item

			@user.interest_list.remove(['first', 'second'])
			@user.save
			@user.interest_list.should have(0).item
			@user.interests.should have(0).item
			Tag.all.should have(2).item
		end

		it 'check remove unexisted interest' do
			@user.interest_list.add(['first', 'second'])
			@user.save
			@user.interest_list.should have(2).item
			@user.interests.should have(2).item
			Tag.all.should have(2).item

			@user.interest_list.remove(['third', 'fourth'])
			@user.save
			@user.interest_list.should have(2).item
			@user.interests.should have(2).item
			Tag.all.should have(2).item
		end
	end

	context 'delete user' do
		it 'user should be deleted' do
			FactoryGirl.create(:user).should be_valid
			User.first.destroy
			User.first.should be_nil
		end
	end

end
