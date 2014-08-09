require 'spec_helper'

describe Api::User::Companies::CreatedCompaniesController do
	context 'actions with user created companies' do
		before :each do
			@correct_user = FactoryGirl.create(:user)
			@id_structure = {id: @correct_user.id}
			@id_wrong_structure = {id: @correct_user.id - 1}
			request.cookies[:ACCESS_TOKEN] = @correct_user.access_token

			@new_user = FactoryGirl.create(:user_second)
			@new_user.should be_valid
			@id_new_user_structure = {id: @new_user.id}
			@invalid_access_token = 'unexist_access_token' #TODO: check created for wrong access token
		end

		it 'check created companies offset' do
			companies = []
			2.times {company = FactoryGirl.create(:company, owner: @correct_user); company.should be_valid; companies.push company}

			get :index, @id_structure.merge({company_limit: 1})
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

			get :index, @id_structure
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
			get :index, @id_structure
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
			get :index, @id_structure
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
end