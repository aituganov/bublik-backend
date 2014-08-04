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
			rs_data['id'].should_not be_nil
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
			rs_data['id'].should_not be_nil
			rs_data['access_token'].should_not be_nil
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

				get :index, @id_structure.merge({company_limit: 7})
				response.status.should eq 200
				rs_user_data = JSON.parse(response.body)['data']
				companies_data = rs_user_data['created_companies']
				companies_data.should_not be_nil
				companies_data.should have(7).item
			end

			it 'unexist user created companies data has 404' do
				@created_company = FactoryGirl.create(:company, owner: @correct_user)
				@created_company.should be_valid

				get :created_companies, @id_wrong_structure
				response.status.should eq 404
			end

			it 'registered user has created companies data' do
				@created_company = FactoryGirl.create(:company, owner: @correct_user)
				@created_company.should be_valid

				get :created_companies, @id_structure
				response.status.should eq 200
				rs_user_data = JSON.parse(response.body)['data']
				companies_data = rs_user_data['created_companies']
				companies_data.should_not be_nil
				companies_data.should have(1).item
				company_data = companies_data[0]
				company_data['id'] = @created_company.id
			end

			it 'check created companies offset' do
				companies = []
				2.times {company = FactoryGirl.create(:company, owner: @correct_user); company.should be_valid; companies.push company}

				get :created_companies, @id_structure.merge({company_limit: 1})
				response.status.should eq 200
				rs_user_data = JSON.parse(response.body)['data']
				companies_data = rs_user_data['created_companies']
				companies_data.should_not be_nil
				companies_data.should have(1).item
				companies_data[0]['id'] = companies[0]['id']

				get :index, @id_structure.merge({company_limit: 1, company_offset: 1})
				response.status.should eq 200
				rs_user_data = JSON.parse(response.body)['data']
				companies_data = rs_user_data['created_companies']
				companies_data.should_not be_nil
				companies_data.should have(1).item
				companies_data[0]['id'] = companies[1]['id']
			end

			it 'check created companies actions for owner' do
				2.times {company = FactoryGirl.create(:company, owner: @correct_user); company.should be_valid }

				get :created_companies, @id_structure
				response.status.should eq 200
				rs_user_data = JSON.parse(response.body)['data']
				companies_data = rs_user_data['created_companies']
				companies_data.should_not be_nil
				companies_data.should have(2).item
				companies_data.each do |company|
					created_actions = company['actions']
					created_actions.should_not be_nil
					created_actions.should have(4).item
					created_actions['create'].should be_false
					created_actions['read'].should be_true
					created_actions['update'].should be_true
					created_actions['destroy'].should be_true
				end
			end

			it 'check created companies actions for not owner' do
				2.times {company = FactoryGirl.create(:company, owner: @correct_user); company.should be_valid }

				request.cookies[:ACCESS_TOKEN] = @new_user.access_token
				get :created_companies, @id_structure
				response.status.should eq 200
				rs_user_data = JSON.parse(response.body)['data']
				companies_data = rs_user_data['created_companies']
				companies_data.should_not be_nil
				companies_data.should have(2).item
				companies_data.each do |company|
					created_actions = company['actions']
					created_actions.should_not be_nil
					created_actions.should have(4).item
					created_actions['create'].should be_false
					created_actions['read'].should be_true
					created_actions['update'].should be_false
					created_actions['destroy'].should be_false
				end
			end

			it 'check created companies actions for anonymous' do
				2.times {company = FactoryGirl.create(:company, owner: @correct_user); company.should be_valid }

				request.cookies[:ACCESS_TOKEN] = ''
				get :created_companies, @id_structure
				response.status.should eq 200
				rs_user_data = JSON.parse(response.body)['data']
				companies_data = rs_user_data['created_companies']
				companies_data.should_not be_nil
				companies_data.should have(2).item
				companies_data.each do |company|
					created_actions = company['actions']
					created_actions.should_not be_nil
					created_actions.should have(4).item
					created_actions['create'].should be_false
					created_actions['read'].should be_true
					created_actions['update'].should be_false
					created_actions['destroy'].should be_false
				end
			end
		end

		context 'update' do
			it 'invalid user access token has 403' do
				request.cookies[:ACCESS_TOKEN] = @invalid_access_token
				post :update, @id_structure
				response.status.should eq 403
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

			it 'should 400 for update with empty interests' do
				put :interests_add, @id_structure
				response.status.should eq 400
			end

			it 'should 404 for update with empty interests & invalid user id' do
				put :interests_add, @id_wrong_structure
				response.status.should eq 404
			end

			it 'should 403 for update with another user' do
				put :interests_add, {id: @new_user.id, interests: ['first tag', 'second_tag']}
				response.status.should eq 403
			end

			it 'should 201 for update with unexisted interests' do
				put :interests_add, {id: @correct_user.id, interests: ['first tag', 'second_tag']}
				response.status.should eq 201
				@correct_user.reload
				@correct_user.interests.should have(2).item
			end

			it 'should 201 for update with duplicated interests' do
				put :interests_add, {id: @correct_user.id,  interests: ['first tag', 'first tag']}
				response.status.should eq 201
				@correct_user.reload
				@correct_user.interests.should have(1).item
			end

			it 'should 400 for delete with empty interests' do
				delete :interests_delete, @id_structure
				response.status.should eq 400
			end

			it 'should 404 for delete with empty interests & invalid user id' do
				delete :interests_delete, @id_wrong_structure
				response.status.should eq 404
			end

			it 'should 403 for delete with another user' do
				delete :interests_delete, {id: @new_user.id, interests: ['first tag', 'second_tag']}
				response.status.should eq 403
				@correct_user.reload
				@correct_user.interests.should have(0).item
			end

			it 'should 201 for delete with unexisted interests' do
				delete :interests_delete, {id: @correct_user.id, interests: ['first tag', 'second_tag']}
				response.status.should eq 200
				@correct_user.reload
				@correct_user.interests.should have(0).item
			end

			it 'should 201 for delete with existed interests' do
				@correct_user.interests_add ['first', 'second', 'third']
				@correct_user.interests.should have(3).item

				delete :interests_delete, {id: @correct_user.id, interests: ['first', 'second']}
				response.status.should eq 200
				@correct_user.interests.should have(1).item
			end

			it 'should 201 for delete with duplicated interests' do
				@correct_user.interests_add ['first']
				@correct_user.interests.should have(1).item

				delete :interests_delete, {id: @correct_user.id, interests: ['first', 'first']}
				response.status.should eq 200
				@correct_user.interests.should have(0).item
			end
		end

		context 'avatar' do
			after :each do
				@correct_user.remove_avatar!
				@correct_user.remove_avatar = true
				@correct_user.save
			end
			it 'should 400 for avatar illegal data' do
				post :update_avatar, {id: @correct_user.id, illegal_data: ''}
				response.status.should eq 400
			end

			it 'should 400 for particial user avatar data' do
				image_path = "#{Rails.root}/spec/controllers/users_controller_spec.rb"
				file_data = File.open(image_path, "rb") { |f| f.read }
				post :update_avatar, {id: @correct_user.id, data: file_data}
				response.status.should eq 400

				post :update_avatar, {id: @correct_user.id, data: file_data, content_type: 'js'}
				response.status.should eq 400

				post :update_avatar, {id: @correct_user.id, data: file_data, content_type: 'js', crop_x: 0}
				response.status.should eq 400

				post :update_avatar, {id: @correct_user.id, data: file_data, content_type: 'js', crop_x: 0, crop_y: 0}
				response.status.should eq 400
			end

			it 'should 400 for illegal avatar content type' do
				image_path = "#{Rails.root}/spec/controllers/users_controller_spec.rb"
				file_data = File.open(image_path, "rb") { |f| f.read }
				post :update_avatar, {id: @correct_user.id, data: file_data, content_type: 'js', crop_x: 0, crop_y: 0, crop_l: 0}
				response.status.should eq 400
			end

			it 'should 200 & coorect urls for legal user avatar data' do
				image_path = "#{Rails.root}/spec/fixtures/images/test.jpg"
				file = File.open(image_path, "rb")
				contents = File.open(image_path, "rb").read
				file.close
				data = Base64.encode64(contents)
				post :update_avatar, {id: @correct_user.id, data: data, content_type: 'image/jpeg', crop_x: 10, crop_y: 10, crop_l:10 }
				response.status.should eq 200
				@correct_user.reload
				@correct_user.avatar.read.should eq File.open(image_path, 'rb').read
				rs_avatar_data = JSON.parse(response.body)['data']['avatar']
				rs_avatar_data.should_not be_nil
				rs_avatar_data['preview_url'].should eq @correct_user.avatar.preview.url
				rs_avatar_data['fullsize_url'].should eq @correct_user.avatar.url
			end

			it 'should 200 & correct urls for legal user avatar data' do
				image_path = "#{Rails.root}/spec/fixtures/images/test.jpg"
				file = File.open(image_path, "rb")
				contents = File.open(image_path, "rb").read
				file.close
				data = Base64.encode64(contents)
				post :update_avatar, {id: @correct_user.id, data: data, content_type: 'image/jpeg', crop_x: 10, crop_y: 10, crop_l:10 }
				response.status.should eq 200
				@correct_user.reload
				@correct_user.avatar.read.should eq File.open(image_path, 'rb').read
				rs_avatar_data = JSON.parse(response.body)['data']['avatar']
				rs_avatar_data.should_not be_nil
				rs_avatar_data['preview_url'].should eq @correct_user.avatar.preview.url
				rs_avatar_data['fullsize_url'].should eq @correct_user.avatar.url
			end

			it 'should 200 & correct preview size' do
				image_path = "#{Rails.root}/spec/fixtures/images/test.jpg"
				file = File.open(image_path, "rb")
				contents = File.open(image_path, "rb").read
				file.close
				data = Base64.encode64(contents)
				post :update_avatar, {id: @correct_user.id, data: data, content_type: 'image/jpeg', crop_x: 10, crop_y: 10, crop_l:10 }
				response.status.should eq 200
				@correct_user.reload

				rs_avatar_data = JSON.parse(response.body)['data']['avatar']
				rs_avatar_data.should_not be_nil
				img = Magick::Image.read( "#{Rails.root}/public/#{rs_avatar_data['preview_url']}" ).first
				img.columns.should eq AppSettings.images.preview_size
				img.rows.should eq AppSettings.images.preview_size
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

			it 'second delete has 400' do
				delete :delete, @id_structure
				response.status.should eq 200
				@correct_user.reload
				@correct_user.is_deleted.should be_true

				delete :delete, @id_structure
				response.status.should eq 404
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
