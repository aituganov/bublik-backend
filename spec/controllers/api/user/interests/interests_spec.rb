require 'spec_helper'

describe Api::User::Interests::InterestsController, type: :controller do
	context 'actions with user interests' do
		before :each do
			@correct_user = FactoryGirl.create(:user)
			@id_structure = {id: @correct_user.id}
			@id_wrong_structure = {id: @correct_user.id - 1}
			request.cookies[:ACCESS_TOKEN] = @correct_user.access_token

			@new_user = FactoryGirl.create(:user_second)
			@new_user.should be_valid
			@id_new_user_structure = {id: @new_user.id}
			@invalid_access_token = 'unexist_access_token'
		end

		it 'should 400 for update with empty interests' do
			put :add, @id_structure
			response.status.should eq 400
		end

		it 'should 404 for update with empty interests & invalid user id' do
			put :add, @id_wrong_structure
			response.status.should eq 404
		end

		it 'should 403 for update with another user' do
			put :add, {id: @new_user.id, interests: ['first tag', 'second_tag']}
			response.status.should eq 403
		end

		it 'should 201 for update with unexisted interests' do
			put :add, {id: @correct_user.id, interests: ['first tag', 'second_tag']}
			response.status.should eq 201
			@correct_user.reload
			@correct_user.interests.should have(2).item
		end

		it 'should 201 for update with duplicated interests' do
			put :add, {id: @correct_user.id,  interests: ['first tag', 'first tag']}
			response.status.should eq 201
			@correct_user.reload
			@correct_user.interests.should have(1).item
		end

		it 'should 400 for delete with empty interests' do
			post :delete, @id_structure
			response.status.should eq 400
		end

		it 'should 404 for delete with empty interests & invalid user id' do
			post :delete, @id_wrong_structure
			response.status.should eq 404
		end

		it 'should 403 for delete with another user' do
			post :delete, {id: @new_user.id, interests: ['first tag', 'second_tag']}
			response.status.should eq 403
			@correct_user.reload
			@correct_user.interests.should have(0).item
		end

		it 'should 201 for delete with unexisted interests' do
			post :delete, {id: @correct_user.id, interests: ['first tag', 'second_tag']}
			response.status.should eq 200
			@correct_user.reload
			@correct_user.interests.should have(0).item
		end

		it 'should 201 for delete with existed interests' do
			@correct_user.interests_add ['first', 'second', 'third']
			@correct_user.interests.should have(3).item

			post :delete, {id: @correct_user.id, interests: ['first', 'second']}
			response.status.should eq 200
			@correct_user.interests.should have(1).item
		end

		it 'should 201 for delete with duplicated interests' do
			@correct_user.interests_add ['first']
			@correct_user.interests.should have(1).item

			post :delete, {id: @correct_user.id, interests: ['first', 'first']}
			response.status.should eq 200
			@correct_user.interests.should have(0).item
		end
	end

end
