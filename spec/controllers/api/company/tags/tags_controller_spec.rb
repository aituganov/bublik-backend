require 'spec_helper'
include TestHelper

describe Api::Company::Tags::TagsController, type: :controller do
	context 'actions with company' do
		before :each do
			@user = FactoryGirl.create(:user)
			request.cookies[:ACCESS_TOKEN] = @user.access_token
			@created_company = FactoryGirl.create(:company, owner_id: @user.id )
			@id_structure = {id: @created_company.id}
		end

		it 'should 404 for update with unexist user' do
			put :add, id: -1
			response.status.should eq 404
		end

		it 'should 400 for update with empty tags' do
			put :add, @id_structure
			response.status.should eq 400
		end

		it 'has 403 for not owner update with unexisted tags' do
			request.cookies[:ACCESS_TOKEN] = FactoryGirl.create(:user_second).access_token
			post :add, @id_structure.merge({tags: ['first tag', 'second_tag']})
			response.status.should eq 403
		end

		it 'should 201 for update with unexisted tags' do
			put :add, @id_structure.merge({tags: ['first tag', 'second_tag']})
			response.status.should eq 201
			@created_company.tags.should have(2).item
		end

		it 'should 201 for update with duplicated tags' do
			put :add, @id_structure.merge({tags: ['first tag', 'first tag']})
			response.status.should eq 201
			@created_company.tags.should have(1).item
		end

		it 'should 400 for delete with empty tags' do
			post :delete, @id_structure
			response.status.should eq 400
		end

		it 'has 403 for not owner delete with unexisted tags' do
			request.cookies[:ACCESS_TOKEN] = FactoryGirl.create(:user_second).access_token
			post :delete, @id_structure.merge({tags: ['first tag', 'second_tag']})
			response.status.should eq 403
		end

		it 'should 201 for delete with unexisted tags' do
			post :delete, @id_structure.merge({tags: ['first tag', 'second_tag']})
			response.status.should eq 200
			@created_company.tags.should have(0).item
		end

		it 'should 201 for delete with existed tags' do
			@created_company.tags_add ['first', 'second', 'third']
			@created_company.tags.should have(3).item

			post :delete, @id_structure.merge({tags: ['first', 'second']})
			response.status.should eq 200
			@created_company.tags.should have(1).item
		end

		it 'should 201 for delete with duplicated tags' do
			@created_company.tags_add ['first']
			@created_company.tags.should have(1).item

			post :delete, @id_structure.merge({tags: ['first', 'first']})
			response.status.should eq 200
			@created_company.tags.should have(0).item
		end
	end

end
