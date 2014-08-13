require 'spec_helper'
include TestHelper

describe Api::Company::CompaniesController, type: :controller do
	before :each do
		@company = FactoryGirl.build(:company)
		@company_data = @company.attributes
		@user = FactoryGirl.create(:user)
		request.cookies[:ACCESS_TOKEN] = @user.access_token
	end

	context 'company registration' do
		it 'has 403 error for empty access token & empty data' do
			request.cookies[:ACCESS_TOKEN] = ''
			put :registration
			response.status.should eq 403
		end

		it 'has 403 error for empty access token & correct data' do
			request.cookies[:ACCESS_TOKEN] = ''
			put :registration, @company_data
			response.status.should eq 403
		end

		it 'has 400 error for correct access token & empty data' do
			put :registration
			response.status.should eq 400
		end

		it 'has 201 for correct access token & correct data' do
			put :registration, @company_data
			response.status.should eq 201
			JSON.parse(response.body)['data']['id'].should_not be_nil
		end
	end

	context 'actions with company' do
		before :each do
			put :registration, @company_data
			response.status.should eq 201
			@created_company = Company.find(JSON.parse(response.body)['data']['id'])
			@id_structure = {id: @created_company}
		end

		context 'change company' do
			context 'update company' do
				it 'has 403 for empty access token & empty data' do
					request.cookies[:ACCESS_TOKEN] = ''
					post :update, @id_structure
					response.status.should eq 403
				end

				it 'has 403 for empty access token & empty data' do
					request.cookies[:ACCESS_TOKEN] = ''
					post :update, @id_structure
					response.status.should eq 403
				end

				it 'has 403 error for empty access token & correct data' do
					request.cookies[:ACCESS_TOKEN] = ''
					post :update, {id: @created_company.id, title: 'New title'}
					response.status.should eq 403
				end

				it 'has 403 for not owner' do
					request.cookies[:ACCESS_TOKEN] = FactoryGirl.create(:user_second).access_token
					post :update, @id_structure
					response.status.should eq 403
				end

				it 'has 404 for unexisted' do
					request.cookies[:ACCESS_TOKEN] = FactoryGirl.create(:user_second).access_token
					post :update, {id: 1}
					response.status.should eq 404
				end

				it 'has 400 for correct access token & illegal data' do
					post :update, {id: @created_company.id, title: generate_random_string(51)}
					response.status.should eq 400
				end

				it 'has 200 for correct access token & empty data' do
					post :update, @id_structure
					response.status.should eq 200
				end

				it 'has 200 for correct access token & correct data' do
					company_second = FactoryGirl.build(:company_second).attributes
					post :update, company_second.merge(@id_structure)
					response.status.should eq 200
					@created_company.reload
					@created_company.title.should eq company_second['title']
					@created_company.slogan.should eq company_second['slogan']
					@created_company.description.should eq company_second['description']
				end
			end

			context 'delete company' do
				it 'has 403 for empty access token' do
					request.cookies[:ACCESS_TOKEN] = ''
					delete :delete, @id_structure
					response.status.should eq 403
				end

				it 'has 403 for not owner' do
					request.cookies[:ACCESS_TOKEN] = FactoryGirl.create(:user_second).access_token
					delete :delete, @id_structure
					response.status.should eq 403
				end

				it 'has 404 for unexisted' do
					request.cookies[:ACCESS_TOKEN] = FactoryGirl.create(:user_second).access_token
					delete :delete, {id: 1}
					response.status.should eq 404
				end

				it 'has 200 for correct access token' do
					delete :delete, @id_structure
					response.status.should eq 200
					@created_company.reload
					@created_company.is_deleted.should be_true
				end

				it 'has 200 for correct access token' do
					delete :delete, @id_structure
					response.status.should eq 200
					@created_company.reload
					@created_company.is_deleted.should be_true
				end

				it 'has 400 for double delete' do
					delete :delete, @id_structure
					response.status.should eq 200

					delete :delete, @id_structure
					response.status.should eq 404
				end
			end
		end

		context 'GET company info' do
			it 'has a 404 response status code for not existed company' do
				get :index, {id: 1}
				response.status.should eq 404
			end

			it 'has a correct info for existed company' do
				put :registration, @id_structure
				get :index, @id_structure
				response.status.should eq 200
				rs_data = JSON.parse(response.body)['data']
				rs_data['id'].to_i.should eq @created_company.id
				rs_data['title'].should eq @created_company.title
				rs_data['slogan'].should eq @created_company.slogan
				rs_data['rating'].should eq @created_company.rating
				rs_data['description'].should eq @created_company.description
				rs_data['tags'].should eq @created_company.tag_list
			end

			it 'has a correct actions for anonymous' do
				request.cookies[:ACCESS_TOKEN] = ''
				get :index, @id_structure
				response.status.should eq 200

				company_actions = JSON.parse(response.body)['data']['actions']
				company_actions.should_not be_nil
				company_actions.should have(4).item
				company_actions['create'].should be_false
				company_actions['read'].should be_true
				company_actions['update'].should be_false
				company_actions['destroy'].should be_false
			end

			it 'has a correct actions for not owner' do
				request.cookies[:ACCESS_TOKEN] = FactoryGirl.create(:user_second).access_token
				get :index, @id_structure
				response.status.should eq 200

				company_actions = JSON.parse(response.body)['data']['actions']
				company_actions.should_not be_nil
				company_actions.should have(4).item
				company_actions['create'].should be_false
				company_actions['read'].should be_true
				company_actions['update'].should be_false
				company_actions['destroy'].should be_false
			end

			it 'has a correct actions for owner' do
				get :index, @id_structure
				response.status.should eq 200

				company_actions = JSON.parse(response.body)['data']['actions']
				company_actions.should_not be_nil
				company_actions.should have(4).item
				company_actions['create'].should be_false
				company_actions['read'].should be_true
				company_actions['update'].should be_true
				company_actions['destroy'].should be_true
			end

			it 'has a correct info for deleted company' do
				put :registration, @company_data
				@created_company = Company.find(JSON.parse(response.body)['data']['id'])
				delete :delete, {id: @created_company.id}
				response.status.should eq 200
				@created_company.reload
				@created_company.is_deleted.should be_true
			end

			context 'social user info' do
				before(:each) do
					7.times do |i|
						# user
						u = FactoryGirl.create(:user, login: "user_#{i}@mail.com");
						u.should be_valid;
						u.follow!(@created_company).should be_true
					end
				end

				it 'get user info has correct social data' do
					get :index, @id_structure
					response.status.should eq 200
					rs = JSON.parse(response.body)['data']
					rs['followers'].should_not be_nil
					rs['followers'].should have(6).items
				end
			end
		end
	end

end
