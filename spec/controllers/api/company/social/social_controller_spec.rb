require 'spec_helper'

describe Api::Company::Social::SocialController, type: :controller do
	context 'social actions' do
		before :each do
			@user = FactoryGirl.create(:user)
			@user.should be_valid
			@company = FactoryGirl.create(:company, owner: @user)
			@company.should be_valid

			@id_structure = {id: @company.id}
			@id_wrong_structure = {id: @company.id - 1}
			request.cookies[:ACCESS_TOKEN] = @user.access_token

			@new_user = FactoryGirl.create(:user_second)
			@new_user.should be_valid
			@new_user.follow!(@company).should be_true
			@user.follow!(@company).should be_true
		end

		it 'has 404 for not existed company' do
			post :followers, @id_wrong_structure
			response.status.should eq 404
		end

		it 'has 200 for anonymous' do
			request.cookies[:ACCESS_TOKEN] = ''
			post :followers, @id_structure
			response.status.should eq 200
		end

		it 'has 200 for not owner token' do
			request.cookies[:ACCESS_TOKEN] = @new_user.access_token
			post :followers, @id_structure
			response.status.should eq 200
		end

		it 'has 401 for wrong access token' do
			request.cookies[:ACCESS_TOKEN] = 'wrong_token'
			post :followers, @id_structure
			response.status.should eq 401
		end

		it 'has 200 & correct data for followers' do
			followers = [].push @new_user, @user

			get :followers, @id_structure
			response.status.should eq 200
			rs_followers = JSON.parse(response.body)['data']
			rs_followers.should have(2).items
			checked = 0
			rs_followers.each do |rs_f|
				followers.each do |f|
					if f.id == rs_f['id']
						rs_f['full_name'].should eq f.full_name
						rs_f['preview_url'].should eq f.get_current_image_preview_url
						checked += 1
					end
				end
			end
			checked.should eq 2
		end

		it 'has correct rs for limit & offset' do
			get :followers, @id_structure.merge({limit: 1, offset: 0})
			response.status.should eq 200
			rs_followers = JSON.parse(response.body)['data']
			rs_followers.should have(1).items
			first_id = rs_followers[0]['id']

			get :followers, @id_structure.merge({limit: 1, offset: 1})
			response.status.should eq 200
			rs_followers = JSON.parse(response.body)['data']
			rs_followers.should have(1).items
			second_id = rs_followers[0]['id']

			first_id.should_not eq second_id
		end
	end
end