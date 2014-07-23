require 'spec_helper'

describe UsersController do
	before :each do
		request.env['HTTP_ACCEPT'] = 'application/json'
		@wrong_user = FactoryGirl.build(:wrong_user)
		@correct_user = FactoryGirl.build(:user)
		@invalid_access_token = 'unexist_access_token'
	end

	context 'user registration' do
		it 'has 422 error for empty user data' do
			put :registration
			response.status.should eq 422
		end

		it 'has 422 error for partial user data' do
			params = {login: @wrong_user.login}
			put :registration, params
			response.status.should eq 422

			params = {login: @wrong_user.login, password: @wrong_user.password}
			put :registration, params
			response.status.should eq 422
		end

		it 'has 422 for wrong login format' do
			put :registration, @wrong_user.as_json
			response.status.should eq 422
		end

		it 'has 201 for correct user data' do
			put :registration, @correct_user.as_json
			response.status.should eq 201
		end

		it 'has access token for correct user data' do
			put :registration, @correct_user.as_json
			response.status.should eq 201
			rs_data = JSON.parse(response.body)['data']
			rs_data['access_token'].should_not be_nil
		end

		it 'has 422 for duplicate user login' do
			@correct_user.save
			put :registration, @correct_user.as_json
			response.status.should eq 422
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
			rs_data['access_token'].should_not be_nil
		end

	end

	context 'GET user info' do

		it 'has a 200 response status code for anonymous user' do
			get :index
			response.status.should eq 200
		end

		it 'has a info for anonymous user' do
			get :index
			isAnonymous = JSON.parse(response.body)['anonymous']
			isAnonymous.should be_true
		end

		it 'info for anonymous user has a menuItems' do
			get :index
			menu = JSON.parse(response.body)['menuItems']
			menu.should_not be_empty
		end

		it 'info for anonymous user has a widgets' do
			get :index
			menu = JSON.parse(response.body)['widgets']
			menu.should_not be_empty
		end

		it 'invalid user access token has 404' do
			request.cookies[:ACCESS_TOKEN] = @invalid_access_token
			get :index
			response.status.should eq 404
		end

		it 'registered user info has 200' do
			@correct_user.save
			user = User.first
			request.cookies[:ACCESS_TOKEN] = user.access_token
			get :index
			response.status.should eq 200
		end

		it 'registered user info has correct data' do
			@correct_user.save
			user = User.first
			request.cookies[:ACCESS_TOKEN] = user.access_token
			get :index
			response.status.should eq 200
			rs_user_data = JSON.parse(response.body)['data']
			rs_user_data['first_name'].should eq user.first_name
			rs_user_data['last_name'].should eq user.last_name
			rs_user_data['city'].should eq user.city
			rs_user_data['is_deleted'].should eq user.is_deleted
		end
	end

	context 'user update' do
		it 'invalid user access token has 404' do
			request.cookies[:ACCESS_TOKEN] = @invalid_access_token
			post :update
			response.status.should eq 404
		end

		it 'user update empty data has 200' do
			@correct_user.save
			user = User.first
			request.cookies[:ACCESS_TOKEN] = user.access_token
			post :update
			response.status.should eq 200
		end

		it 'user illegal data not change object' do
			@correct_user.save
			user = User.first
			request.cookies[:ACCESS_TOKEN] = user.access_token
			post :update, {illegal_data: 'test_illegal_data'}
			response.status.should eq 200
			user[:illegal_data].should be_nil
		end

		it 'legal user data change object' do
			@correct_user.save
			user = User.first
			new_first_name = 'ChangedFN'
			new_last_name = 'ChangedLN'
			request.cookies[:ACCESS_TOKEN] = user.access_token
			post :update, {first_name: new_first_name, last_name: new_last_name}
			response.status.should eq 200
			user.reload
			user.first_name.should eq new_first_name
			user.last_name.should eq new_last_name
		end
	end

	context 'user delete' do
		it 'invalid user access_token has 404' do
			request.cookies[:ACCESS_TOKEN] =
			delete :delete
			response.status.should eq 404
		end

		it 'valid user access_token marked object as deleted' do
			@correct_user.save
			user = User.first
			request.cookies[:ACCESS_TOKEN] = user.access_token
			delete :delete
			response.status.should eq 200
			user = user.reload
			user.is_deleted.should be_true
		end

		it 'second delete has 400' do
			@correct_user.save
			user = User.first
			request.cookies[:ACCESS_TOKEN] = user.access_token
			delete :delete
			response.status.should eq 200
			user = user.reload
			user.is_deleted.should be_true

			delete :delete
			response.status.should eq 400
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
