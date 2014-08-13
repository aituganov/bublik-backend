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
	context 'existed user actions' do
		before (:each) do
			@user = FactoryGirl.create(:user)
			@user.should be_valid
		end

		context 'update user' do
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

		context 'check instance methods' do
			context 'check public methods' do
				it 'full_name has correct data' do
					@user.full_name.should eq "#{@user.first_name} #{@user.last_name}"
				end

				it 'get_current_image has nil for unexisted avatar' do
					@user.get_current_image.should be_nil
				end

				it 'get_current_image_preview_url has nil for unexisted avatar' do
					@user.get_current_image_preview_url.should be_nil
				end

				it 'get_current_image has correct avatar' do
					@image = FactoryGirl.create(:image, imageable: @user, current: true)
					@user.get_current_image.should eq @image
				end

				it 'get_current_image_preview_url has correct url' do
					@image = FactoryGirl.create(:image, imageable: @user, current: true)
					@user.get_current_image_preview_url.should eq @image.file.preview.url
				end
			end
			context 'check privileges' do
				after(:each) do
					@actions.should_not be_nil
					@actions[:create].should be_false
					@actions[:read].should be_true
					@actions[:update].should eq !@only_read
					@actions[:destroy].should eq !@only_read
				end

				it 'build privileges response has correct data for anonymous' do
					rs = @user.build_response({User.RS_DATA[:PRIVILEGES] => true})
					@actions = rs[:actions]
					@only_read = true
				end

				it 'build privileges response has correct data for not owner' do
					rs = @user.build_response({User.RS_DATA[:PRIVILEGES] => true}, {access_token: 'another_user'})
					@actions = rs[:actions]
					@only_read = true
				end

				it 'build privileges response has correct data for owner' do
					rs = @user.build_response({User.RS_DATA[:PRIVILEGES] => true}, {access_token: @user.access_token})
					@actions = rs[:actions]
					@only_read = false
				end
			end

			context 'check avatar' do
				before(:each) do
					@image = FactoryGirl.create(:image, imageable: @user, current: true)
				end
				after(:each) do
					@avatar.should_not be_nil
					@avatar[:id].should eq @image.id
					@avatar[:current].should eq @image.current
					@avatar[:fullsize_url].should eq @image.file.url
					@avatar[:preview_url].should eq @image.file.preview.url

					@actions = @avatar[:actions]
					@actions.should_not be_nil
					@actions[:create].should be_false
					@actions[:read].should be_true
					@actions[:update].should eq !@only_read
					@actions[:destroy].should eq !@only_read
				end

				it 'build avatar response has correct data for anonymous' do
					rs = @user.build_response({User.RS_DATA[:AVATAR] => true})
					@avatar = rs[User.RS_DATA[:AVATAR]]
					@only_read = true
				end

				it 'build avatar response has correct data for not owner' do
					rs = @user.build_response({User.RS_DATA[:AVATAR] => true}, {access_token: 'another_user'})
					@avatar = rs[User.RS_DATA[:AVATAR]]
					@only_read = true
				end

				it 'build avatar response has correct data for owner' do
					rs = @user.build_response({User.RS_DATA[:AVATAR] => true}, {access_token: @user.access_token})
					@avatar = rs[User.RS_DATA[:AVATAR]]
					@only_read = false
				end
			end

			context 'check tags' do
				before(:each) do
					@user.interests_add %w(first second)
				end

				after(:each) do
					@tags.should_not be_nil
					@tags.should have(2).items
					@tags[0].should eq 'first'
					@tags[1].should eq 'second'
				end

				it 'build interests response has correct data for anonymous' do
					rs = @user.build_response({User.RS_DATA[:INTERESTS] => true})
					@tags = rs[User.RS_DATA[:INTERESTS]]
				end

				it 'build interests response has correct data for not owner' do
					rs = @user.build_response({User.RS_DATA[:INTERESTS] => true}, {access_token: 'another_user'})
					@tags = rs[User.RS_DATA[:INTERESTS]]
				end

				it 'build interests response has correct data for owner' do
					rs = @user.build_response({User.RS_DATA[:INTERESTS] => true}, {access_token: @user.access_token})
					@tags = rs[User.RS_DATA[:INTERESTS]]
				end
			end
		end
		context 'delete user' do
			it 'user should be deleted' do
				@user.destroy
				User.first.should be_nil
			end
		end
	end

end
