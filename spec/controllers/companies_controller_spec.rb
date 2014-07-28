require 'spec_helper'

describe CompaniesController do
	before :each do
		@company = FactoryGirl.build(:company)
		@company_data = @company.attributes
		@user = FactoryGirl.create(:user)
		request.cookies[:ACCESS_TOKEN] = @user.access_token
	end

	context 'company registration' do
		it 'has 404 error for empty access token & empty data' do
			request.cookies[:ACCESS_TOKEN] = ''
			put :registration
			response.status.should eq 404
		end

		it 'has 404 error for empty access token & correct data' do
			request.cookies[:ACCESS_TOKEN] = ''
			put :registration, @company_data
			response.status.should eq 404
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

	context 'change company' do
		before :each do
			put :registration, @company_data
			@created_company = Company.find(JSON.parse(response.body)['data']['id'])
		end

		context 'update company' do
			it 'has 404 for empty access token & empty data' do
				request.cookies[:ACCESS_TOKEN] = ''
				post :update, {id: @created_company.id}
				response.status.should eq 404
			end

			it 'has 404 for empty access token & empty data' do
				request.cookies[:ACCESS_TOKEN] = ''
				post :update, {id: @created_company.id}
				response.status.should eq 404
			end

			it 'has 404 error for empty access token & correct data' do
				request.cookies[:ACCESS_TOKEN] = ''
				post :update, {id: @created_company.id, title: 'New title'}
				response.status.should eq 404
			end

			it 'has 406 for not owner' do
				request.cookies[:ACCESS_TOKEN] = FactoryGirl.create(:user_second).access_token
				post :update, {id: @created_company.id}
				response.status.should eq 406
			end

			it 'has 404 for unexisted' do
				request.cookies[:ACCESS_TOKEN] = FactoryGirl.create(:user_second).access_token
				post :update, {id: 1}
				response.status.should eq 404
			end

			it 'has 200 for correct access token & empty data' do
				post :update, {id: @created_company.id}
				response.status.should eq 200
			end

			it 'has 200 for correct access token & correct data' do
				company_second = FactoryGirl.build(:company_second).attributes
				post :update, company_second.merge({id: @created_company.id})
				response.status.should eq 200
				@created_company.reload
				@created_company.title.should eq company_second['title']
				@created_company.slogan.should eq company_second['slogan']
				@created_company.description.should eq company_second['description']
			end
		end

		context 'delete company' do
			it 'has 404 for empty access token' do
				request.cookies[:ACCESS_TOKEN] = ''
				delete :delete, {id: @created_company.id}
				response.status.should eq 404
			end

			it 'has 406 for not owner' do
				request.cookies[:ACCESS_TOKEN] = FactoryGirl.create(:user_second).access_token
				delete :delete, {id: @created_company.id}
				response.status.should eq 406
			end

			it 'has 404 for unexisted' do
				request.cookies[:ACCESS_TOKEN] = FactoryGirl.create(:user_second).access_token
				delete :delete, {id: 1}
				response.status.should eq 404
			end

			it 'has 200 for correct access token' do
				delete :delete, {id: @created_company.id}
				response.status.should eq 200
				@created_company.reload
				@created_company.is_deleted.should be_true
			end

			it 'has 200 for correct access token' do
				delete :delete, {id: @created_company.id}
				response.status.should eq 200
				@created_company.reload
				@created_company.is_deleted.should be_true
			end

			it 'has 400 for double delete' do
				delete :delete, {id: @created_company.id}
				response.status.should eq 200

				delete :delete, {id: @created_company.id}
				response.status.should eq 400
			end
		end
	end

	context 'GET company info' do
		it 'has a 200 response status code' do
			get 'get', {id: 1}
			response.status.should eq 200
		end

		it 'has a fake info for unexisted company' do
			id = 1
			get 'get', {id: id}
			response.status.should eq 200
			rs_data = JSON.parse(response.body)['data']
			rs_data['id'].to_i.should eq id
			rs_data['is_fake'].should be_true
		end

		it 'has a correct info for existed company' do
			put :registration, @company_data
			@created_company = Company.find(JSON.parse(response.body)['data']['id'])
			get 'get', {id: @created_company.id}
			response.status.should eq 200
			rs_data = JSON.parse(response.body)['data']
			rs_data['id'].to_i.should eq @created_company.id
			rs_data['title'].should eq @created_company.title
			rs_data['slogan'].should eq @created_company.slogan
			rs_data['description'].should eq @created_company.description
		end

		it 'has a correct info for deleted company' do
			put :registration, @company_data
			id = JSON.parse(response.body)['data']['id']
			delete :delete, {id: id}
			response.status.should eq 200
			get 'get', {id: id}
			response.status.should eq 200
			rs_data = JSON.parse(response.body)['data']
			rs_data['is_deleted'].should be_true
		end
	end

end
