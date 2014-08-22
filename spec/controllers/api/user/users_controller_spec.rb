require 'spec_helper'

describe Api::User::UsersController, type: :controller do
	before :each do
		@wrong_user = FactoryGirl.build(:wrong_user)
		@correct_user = FactoryGirl.build(:user)
		@invalid_access_token = 'unexist_access_token'
	end

	context 'user registration' do
		it 'has 400 error for empty user data' do
			put :registration
			response.status.should eq 400
		end

		it 'has 400 error for partial user data' do
			params = {login: @wrong_user.login}
			put :registration, params
			response.status.should eq 400

			params = {login: @wrong_user.login, password: @wrong_user.password}
			put :registration, params
			response.status.should eq 400
		end

		it 'has 400 for wrong login format' do
			put :registration, @wrong_user.as_json
			response.status.should eq 400
		end

		it 'has 201 for correct user data' do
			put :registration, @correct_user.as_json
			response.status.should eq 201
		end

		it 'has access token for correct user data' do
			put :registration, @correct_user.as_json
			response.status.should eq 201
			rs_data = JSON.parse(response.body)['data']
			rs_data['id'].should_not be_nil
			rs_data['access_token'].should_not be_nil
		end

		it 'has 400 for duplicate user login' do
			@correct_user.save
			put :registration, @correct_user.as_json
			response.status.should eq 400
		end
	end

	context 'user login' do
		it 'unregistered user login has 401' do
			put :login, {login: @correct_user.login, password: @correct_user.password}
			response.status.should eq 401
		end

		it 'registerd user login has 200' do
			@correct_user.save
			put :login, {login: @correct_user.login, password: @correct_user.password}
			response.status.should eq 200
		end

		it 'registerd user login has access_token' do
			@correct_user.save
			put :login, {login: @correct_user.login, password: @correct_user.password}
			response.status.should eq 200
			rs_data = JSON.parse(response.body)['data']
			rs_data['id'].should_not be_nil
			rs_data['access_token'].should_not be_nil
		end
	end

	context 'user logout' do
		it 'empty access token has 401' do
			put :logout
			response.status.should eq 405
		end

		it 'wrong access token has 401' do
			request.cookies[:ACCESS_TOKEN] = 'wrong_access_token'
			put :logout
			response.status.should eq 401
		end

		it 'correct access token has 200' do
			@correct_user.save
			request.cookies[:ACCESS_TOKEN] = @correct_user.access_token
			put :logout
			response.status.should eq 200
		end
	end

	context 'actions with user' do
		before :each do
			@correct_user.save
			@id_structure = {id: @correct_user.id}
			@id_wrong_structure = {id: @correct_user.id - 1}
			request.cookies[:ACCESS_TOKEN] = @correct_user.access_token

			@new_user = FactoryGirl.create(:user_second)
			@new_user.should be_valid
			@id_new_user_structure = {id: @new_user.id}
		end

		context 'info' do
			it 'unexisted user has a 404 response status code for anonymous' do
				request.cookies[:ACCESS_TOKEN] = ''
				get :index, @id_wrong_structure
				response.status.should eq 404
			end

			it 'existed user has a 200 response status code for anonymous' do
				request.cookies[:ACCESS_TOKEN] = ''
				get :index, @id_structure
				response.status.should eq 200

				user_actions = JSON.parse(response.body)['data']['actions']
				user_actions.should_not be_nil
				user_actions.should have(4).item
				user_actions['create'].should be_false
				user_actions['read'].should be_true
				user_actions['update'].should be_false
				user_actions['destroy'].should be_false
			end

			it 'existed user has a info for anonymous user' do
				request.cookies[:ACCESS_TOKEN] = ''
				get :index, @id_structure
				response.status.should eq 200

				user_actions = JSON.parse(response.body)['data']['actions']
				user_actions.should_not be_nil
				user_actions.should have(4).item
				user_actions['create'].should be_false
				user_actions['read'].should be_true
				user_actions['update'].should be_false
				user_actions['destroy'].should be_false
			end

			it 'existed user has a info for another user' do
				get :index, @id_new_user_structure
				response.status.should eq 200

				user_actions = JSON.parse(response.body)['data']['actions']
				user_actions.should_not be_nil
				user_actions.should have(4).item
				user_actions['create'].should be_false
				user_actions['read'].should be_true
				user_actions['update'].should be_false
				user_actions['destroy'].should be_false
			end

			it 'unexisted user has a 404 response status code for registered' do
				get :index, @id_wrong_structure
				response.status.should eq 404
			end

			it 'registered user info has 200' do
				get :index, @id_structure
				response.status.should eq 200
			end

			it 'registered user info has correct data' do
				get :index, @id_structure
				response.status.should eq 200
				rs_user_data = JSON.parse(response.body)['data']
				rs_user_data['id'].should eq @correct_user.id
				rs_user_data['full_name'].should eq @correct_user.full_name
				rs_user_data['first_name'].should eq @correct_user.first_name
				rs_user_data['last_name'].should eq @correct_user.last_name
				rs_user_data['is_deleted'].should eq @correct_user.is_deleted
				rs_user_data['interests'].should eq @correct_user.interest_list

				user_actions = rs_user_data['actions']
				user_actions.should_not be_nil
				user_actions.should have(4).item
				user_actions['create'].should be_false
				user_actions['read'].should be_true
				user_actions['update'].should be_true
				user_actions['destroy'].should be_true
			end

			it 'registered user info has correct interests data' do
				@correct_user.interest_list.add %w(first second)
				@correct_user.reload

				get :index, @id_structure
				response.status.should eq 200
				rs_user_data = JSON.parse(response.body)['data']
				rs_user_data['interests'].should eq @correct_user.interest_list
			end

			it 'registered user info has correct created companies data' do
				@created_company = FactoryGirl.create(:company, owner: @correct_user)
				@created_company.should be_valid

				get :index, @id_structure
				response.status.should eq 200
				rs_user_data = JSON.parse(response.body)['data']
				companies_data = rs_user_data['created_companies']
				companies_data.should_not be_nil
				companies_data.should have(1).item
				company_data = companies_data[0]
				company_data['id'] = @created_company.id
			end

			it 'registered user info has correct default company limit' do
				7.times {company = FactoryGirl.create(:company, owner: @correct_user); company.should be_valid}

				get :index, @id_structure
				response.status.should eq 200
				rs_user_data = JSON.parse(response.body)['data']
				companies_data = rs_user_data['created_companies']
				companies_data.should_not be_nil
				companies_data.should have(6).item
			end

			it 'registered user info has correct data for defined company limit' do
				7.times {company = FactoryGirl.create(:company, owner: @correct_user); company.should be_valid}

				get :index, @id_structure.merge({limit: 7})
				response.status.should eq 200
				rs_user_data = JSON.parse(response.body)['data']
				companies_data = rs_user_data['created_companies']
				companies_data.should_not be_nil
				companies_data.should have(7).item
			end

			it 'unexist user created companies data has 404' do
				@created_company = FactoryGirl.create(:company, owner: @correct_user)
				@created_company.should be_valid

				get :index, @id_wrong_structure
				response.status.should eq 404
			end

			it 'registered user has created companies data' do
				@created_company = FactoryGirl.create(:company, owner: @correct_user)
				@created_company.should be_valid

				get :index, @id_structure
				response.status.should eq 200
				rs_user_data = JSON.parse(response.body)['data']
				companies_data = rs_user_data['created_companies']
				companies_data.should_not be_nil
				companies_data.should have(1).item
				company_data = companies_data[0]
				company_data['id'] = @created_company.id
			end

			context 'social preview user info' do
				before(:each) do
					@users = []
					@companies = []
					7.times do |i|
						# user
						u = FactoryGirl.create(:user, login: "user_#{i}@mail.com");
						u.should be_valid;
						@users.push(u)
						@correct_user.follow!(u).should be_true
						u.follow!(@correct_user).should be_true
						# company
						c = FactoryGirl.create(:company, owner: u, title: u.full_name);
						c.should be_valid;
						@companies.push(c)
						@correct_user.follow!(c).should be_true
					end
				end

				it 'get user info has correct social data' do
					get :index, @id_structure
					response.status.should eq 200
					rs = JSON.parse(response.body)['data']
					social = rs['social']
					social.should_not be_nil
					social['actions'].should_not be_nil
					social['actions'].should have(2).items

					social['followed_users'].should_not be_nil
					social['followed_users'].should have(6).items

					social['followed_companies'].should_not be_nil
					social['followed_companies'].should have(6).items

					social['followers'].should_not be_nil
					social['followers'].should have(6).items
				end
			end

			context 'correct social actions' do
				after(:each) do
					@social_actions.should have(2).items
					@social_actions['follow'].should eq @can_follow || false
					@social_actions['unfollow'].should eq @can_unfollow || false
				end

				it 'anonymous has correct actions' do
					request.cookies[:ACCESS_TOKEN] = ''
					get :index, @id_structure
					response.status.should eq 200
					@social_actions = JSON.parse(response.body)['data']['social']['actions']
				end

				it 'himself has correct actions' do
					get :index, @id_structure
					response.status.should eq 200
					@social_actions = JSON.parse(response.body)['data']['social']['actions']
				end

				it 'another user info has correct actions' do
					get :index, @id_new_user_structure
					response.status.should eq 200
					@social_actions = JSON.parse(response.body)['data']['social']['actions']
					@can_follow = true
				end

				it 'already followes info has correct actions' do
					@correct_user.follow!(@new_user).should be_true
					get :index, @id_new_user_structure
					response.status.should eq 200
					@social_actions = JSON.parse(response.body)['data']['social']['actions']
					@can_unfollow = true
				end
			end

			it 'wrong access token has 401' do
				cookies['ACCESS_TOKEN'] = 'illegal'
				get :current
				response.status.should eq 401
			end

			it 'empty access token has anonymous' do
				cookies['ACCESS_TOKEN'] = ''
				get :current
				response.status.should eq 200

				rs = JSON.parse(response.body)['data']
				rs['info']['anonymous'].should be_true
				rs['menu_items'].should have(0).items
			end

			it 'valid access token has data' do
				get :current
				response.status.should eq 200

				rs = JSON.parse(response.body)['data']
				rs_user = rs['info']
				rs_user['anonymous'].should be_nil
				rs_user['id'].should eq @correct_user.id
				rs_user['full_name'].should eq @correct_user.full_name
				rs_user['avatar_preview_url'].should eq @correct_user.get_current_image_preview_url
				rs['menu_items'].should_not have(0).items
			end
		end

		context 'update' do
			it 'wrong access token has 401' do
				request.cookies[:ACCESS_TOKEN] = @invalid_access_token
				post :update, @id_structure
				response.status.should eq 401
			end

			it 'invalid user id has 404' do
				post :update, @id_wrong_structure
				response.status.should eq 404
			end

			it 'user update another user has 403' do
				post :update, @id_new_user_structure
				response.status.should eq 403
			end

			it 'user update empty data has 200' do
				post :update, @id_structure
				response.status.should eq 200
			end

			it 'user illegal data not change object' do
				post :update, {id: @correct_user.id, illegal_data: 'test_illegal_data'}
				response.status.should eq 200
				@correct_user[:illegal_data].should be_nil
			end

			it 'user wrong login not change object' do
				login_wrong = 'wrong'
				post :update, {id: @correct_user.id, login: login_wrong}
				response.status.should eq 400
				@correct_user[:login].should_not eq login_wrong
			end

			it 'legal user data change object' do
				new_first_name = 'ChangedFN'
				new_last_name = 'ChangedLN'
				post :update, {id: @correct_user.id, first_name: new_first_name, last_name: new_last_name}
				response.status.should eq 200
				@correct_user.reload
				@correct_user.first_name.should eq new_first_name
				@correct_user.last_name.should eq new_last_name
			end
		end

		context 'delete' do
			it 'invalid user access_token has 403' do
				request.cookies[:ACCESS_TOKEN] = ''
				delete :delete, @id_structure
				response.status.should eq 403
			end

			it 'another user has 403' do
				request.cookies[:ACCESS_TOKEN] = ''
				delete :delete, @id_new_user_structure
				response.status.should eq 403
			end

			it 'invalid user id has 404' do
				delete :delete, @id_wrong_structure
				response.status.should eq 404
			end

			it 'valid user access_token marked object as deleted' do
				delete :delete, @id_structure
				response.status.should eq 200
				@correct_user.reload
				@correct_user.is_deleted.should be_true
			end

			it 'second delete has 401' do
				delete :delete, @id_structure
				response.status.should eq 200
				@correct_user.reload
				@correct_user.is_deleted.should be_true

				delete :delete, @id_structure
				response.status.should eq 401
			end
		end
	end
	context 'check login' do
		it 'check empty data return 200' do
			get :check_login, login: ''
			response.status.should eq 200
		end

		it 'check unexisted return 200' do
			get :check_login, login: 'new'
			response.status.should eq 200
		end

		it 'check existed return 201' do
			@correct_user.save
			get :check_login, login: @correct_user.login
			response.status.should eq 201
		end
	end

end
