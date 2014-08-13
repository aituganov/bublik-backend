require 'spec_helper'

describe Api::User::Social::SocialController, type: :controller do
	context 'social actions' do
		before :each do
			@user = FactoryGirl.create(:user)
			@id_structure = {id: @user.id}
			@id_wrong_structure = {id: @user.id - 1}
			request.cookies[:ACCESS_TOKEN] = @user.access_token

			@new_user = FactoryGirl.create(:user_second)
			@new_user.should be_valid
			@id_new_user_structure = {id: @new_user.id}
			@invalid_access_token = 'unexist_access_token'
		end

		describe 'user' do
			before(:each) do
				@followed_user = FactoryGirl.create(:user_third)
				@followed_user.should be_valid
			end

			describe 'follow user' do
				it 'has 404 for not existed follower' do
					post :user_follow, @id_wrong_structure.merge({user_id: @followed_user.id})
					response.status.should eq 404
				end

				it 'has 404 for not existed followed' do
					post :user_follow, @id_structure.merge({user_id: @followed_user.id + 10})
					response.status.should eq 404
				end

				it 'has 403 for anonymous' do
					request.cookies[:ACCESS_TOKEN] = ''
					post :user_follow, @id_structure.merge({user_id: @followed_user.id})
					response.status.should eq 403
				end

				it 'has 403 for wrong token' do
					request.cookies[:ACCESS_TOKEN] = @new_user.access_token
					post :user_follow, @id_structure.merge({user_id: @followed_user.id})
					response.status.should eq 403
				end

				it 'has 200 for correct params' do
					post :user_follow, @id_structure.merge({user_id: @followed_user.id})
					response.status.should eq 200
					@user.follows?(@followed_user).should be_true
				end

				it 'has 200 for many follows' do
					@user.followees(User).should have(0).items
					post :user_follow, @id_structure.merge({user_id: @followed_user.id})
					response.status.should eq 200
					@user.follows?(@followed_user).should be_true

					post :user_follow, @id_structure.merge({user_id: @new_user.id})
					response.status.should eq 200
					@user.follows?(@new_user).should be_true
					get :user_followed, @id_structure
					response.status.should eq 200

					@user.followees(User).should have(2).items
				end

				it 'has 403 for double follow' do
					post :user_follow, @id_structure.merge({user_id: @followed_user.id})
					response.status.should eq 200
					@user.follows?(@followed_user).should be_true

					post :user_follow, @id_structure.merge({user_id: @followed_user.id})
					response.status.should eq 403
				end
			end

			describe 'unfollow user' do
				before(:each) do
					@user.follow!(@new_user).should be_true
					@user.follow!(@followed_user).should be_true
				end
				it 'has 404 for not existed follower' do
					post :user_unfollow, @id_wrong_structure.merge({user_id: @followed_user.id})
					response.status.should eq 404
				end

				it 'has 404 for not existed followed' do
					post :user_unfollow, @id_structure.merge({user_id: @followed_user.id + 10})
					response.status.should eq 404
				end

				it 'has 403 for anonymous' do
					request.cookies[:ACCESS_TOKEN] = ''
					post :user_unfollow, @id_structure.merge({user_id: @followed_user.id})
					response.status.should eq 403
				end

				it 'has 403 for wrong token' do
					request.cookies[:ACCESS_TOKEN] = @new_user.access_token
					post :user_unfollow, @id_structure.merge({user_id: @followed_user.id})
					response.status.should eq 403
				end

				it 'has 200 for correct params' do
					post :user_unfollow, @id_structure.merge({user_id: @followed_user.id})
					response.status.should eq 200
					@user.follows?(@followed_user).should be_false
				end

				it 'has 403 for double unfollow' do
					post :user_unfollow, @id_structure.merge({user_id: @followed_user.id})
					response.status.should eq 200
					@user.follows?(@followed_user).should be_false

					post :user_unfollow, @id_structure.merge({user_id: @followed_user.id})
					response.status.should eq 403
				end

				it 'has 200 for many follows' do
					@user.followees(User).should have(2).items
					post :user_unfollow, @id_structure.merge({user_id: @followed_user.id})
					response.status.should eq 200
					@user.follows?(@followed_user).should be_false

					post :user_unfollow, @id_structure.merge({user_id: @new_user.id})
					response.status.should eq 200
					@user.follows?(@new_user).should be_false
					@user.followees(User).should have(0).items
				end
			end

			describe 'check followed users rs' do
				before(:each) do
					@user.follow!(@new_user).should be_true
					@user.follow!(@followed_user).should be_true
				end

				it 'has 404 for not existed user' do
					post :user_followed, @id_wrong_structure
					response.status.should eq 404
				end

				it 'has 200 for anonymous' do
					request.cookies[:ACCESS_TOKEN] = ''
					post :user_followed, @id_structure
					response.status.should eq 200
				end

				it 'has 200 for not owner token' do
					request.cookies[:ACCESS_TOKEN] = @new_user.access_token
					post :user_followed, @id_structure
					response.status.should eq 200
				end

				it 'has 200 for not wrong access token' do
					request.cookies[:ACCESS_TOKEN] = 'wrong_token'
					post :user_followed, @id_structure
					response.status.should eq 200
				end

				it 'has 200 & correct data for followed users' do
					followed = [].push @new_user, @followed_user

					get :user_followed, @id_structure
					response.status.should eq 200
					rs_followed = JSON.parse(response.body)['data']
					rs_followed.should have(2).items
					checked = 0
					rs_followed.each do |rs_f|
						followed.each do |f|
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
					get :user_followed, @id_structure.merge({limit: 1, offset: 0})
					response.status.should eq 200
					rs_followed = JSON.parse(response.body)['data']
					rs_followed.should have(1).items
					first_id = rs_followed[0]['id']

					get :user_followed, @id_structure.merge({limit: 1, offset: 1})
					response.status.should eq 200
					rs_followed = JSON.parse(response.body)['data']
					rs_followed.should have(1).items
					second_id = rs_followed[0]['id']

					first_id.should_not eq second_id
				end
			end

			describe 'check followers rs' do
				before(:each) do
					@new_user.follow!(@followed_user).should be_true
					@user.follow!(@followed_user).should be_true
					@id_structure = {id: @followed_user.id}
				end

				it 'has 404 for not existed user' do
					post :user_followers, @id_wrong_structure
					response.status.should eq 404
				end

				it 'has 200 for anonymous' do
					request.cookies[:ACCESS_TOKEN] = ''
					post :user_followers, @id_structure
					response.status.should eq 200
				end

				it 'has 200 for not owner token' do
					request.cookies[:ACCESS_TOKEN] = @new_user.access_token
					post :user_followers, @id_structure
					response.status.should eq 200
				end

				it 'has 200 for not wrong access token' do
					request.cookies[:ACCESS_TOKEN] = 'wrong_token'
					post :user_followers, @id_structure
					response.status.should eq 200
				end

				it 'has 200 & correct data for user followers' do
					followed = [].push @new_user, @user

					get :user_followers, @id_structure
					response.status.should eq 200
					rs_followed = JSON.parse(response.body)['data']
					rs_followed.should have(2).items
					checked = 0
					rs_followed.each do |rs_f|
						followed.each do |f|
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
					get :user_followers, @id_structure.merge({limit: 1, offset: 0})
					response.status.should eq 200
					rs_followed = JSON.parse(response.body)['data']
					rs_followed.should have(1).items
					first_id = rs_followed[0]['id']

					get :user_followers, @id_structure.merge({limit: 1, offset: 1})
					response.status.should eq 200
					rs_followed = JSON.parse(response.body)['data']
					rs_followed.should have(1).items
					second_id = rs_followed[0]['id']

					first_id.should_not eq second_id
				end
			end
		end

		describe 'company' do
			before(:each) do
				@companies = []
				2.times {company = FactoryGirl.create(:company, owner: @new_user); company.should be_valid; @companies.push company}
				@company_first = @companies[0]
				@company_second = @companies[1]
				@rq_params = @id_structure.merge({company_id: @company_first.id})
			end

			describe 'follow company' do
				it 'has 404 for not existed follower' do
					post :company_follow, @id_wrong_structure.merge({company_id: @company_first.id})
					response.status.should eq 404
				end

				it 'has 404 for not existed followed' do
					post :company_follow, @id_structure.merge({company_id: @company_first.id + 10})
					response.status.should eq 404
				end

				it 'has 403 for anonymous' do
					request.cookies[:ACCESS_TOKEN] = ''
					post :company_follow, @rq_params
					response.status.should eq 403
				end

				it 'has 403 for wrong token' do
					request.cookies[:ACCESS_TOKEN] = @new_user.access_token
					post :company_follow, @rq_params
					response.status.should eq 403
				end

				it 'has 200 for correct params' do
					post :company_follow, @rq_params
					response.status.should eq 200
					@user.follows?(@company_first).should be_true
				end

				it 'has 200 for many follows' do
					@user.followees(Company).should have(0).items
					post :company_follow, @rq_params
					response.status.should eq 200
					@user.follows?(@company_first).should be_true

					post :company_follow, @id_structure.merge({company_id: @company_second.id})
					response.status.should eq 200
					@user.follows?(@company_second).should be_true
					get :company_followed, @id_structure
					response.status.should eq 200

					@user.followees(Company).should have(2).items
				end

				it 'has 403 for double follow' do
					post :company_follow, @rq_params
					response.status.should eq 200
					@user.follows?(@company_first).should be_true

					post :company_follow, @rq_params
					response.status.should eq 403
				end
			end

			describe 'unfollow company' do
				before(:each) do
					@user.follow!(@company_first).should be_true
					@user.follow!(@company_second).should be_true
				end
				it 'has 404 for not existed follower' do
					post :company_unfollow, @id_wrong_structure.merge({company_id: @company_first.id})
					response.status.should eq 404
				end

				it 'has 404 for not existed followed' do
					post :company_unfollow, @id_structure.merge({company_id: @company_first.id + 10})
					response.status.should eq 404
				end

				it 'has 403 for anonymous' do
					request.cookies[:ACCESS_TOKEN] = ''
					post :company_unfollow, @rq_params
					response.status.should eq 403
				end

				it 'has 403 for wrong token' do
					request.cookies[:ACCESS_TOKEN] = @new_user.access_token
					post :company_unfollow, @rq_params
					response.status.should eq 403
				end

				it 'has 200 for correct params' do
					post :company_unfollow, @rq_params
					response.status.should eq 200
					@user.follows?(@company_first).should be_false
				end

				it 'has 403 for double unfollow' do
					post :company_unfollow, @rq_params
					response.status.should eq 200
					@user.follows?(@company_first).should be_false

					post :company_unfollow, @rq_params
					response.status.should eq 403
				end

				it 'has 200 for many follows' do
					@user.followees(Company).should have(2).items
					post :company_unfollow, @rq_params
					response.status.should eq 200
					@user.follows?(@company_first).should be_false

					post :company_unfollow, @id_structure.merge({company_id: @company_second.id})
					response.status.should eq 200
					@user.follows?(@company_second).should be_false

					@user.followees(Company).should have(0).items
				end
			end

			describe 'check followed companies rs' do
				before(:each) do
					@companies.each { |c| @user.follow!(c).should be_true}
				end

				it 'has 404 for not existed user' do
					post :company_followed, @id_wrong_structure
					response.status.should eq 404
				end

				it 'has 200 for anonymous' do
					request.cookies[:ACCESS_TOKEN] = ''
					post :company_followed, @id_structure
					response.status.should eq 200
				end

				it 'has 200 for not owner token' do
					request.cookies[:ACCESS_TOKEN] = @new_user.access_token
					post :company_followed, @id_structure
					response.status.should eq 200
				end

				it 'has 200 for not wrong access token' do
					request.cookies[:ACCESS_TOKEN] = 'wrong_token'
					post :company_followed, @id_structure
					response.status.should eq 200
				end

				it 'has 200 & correct data for followed companies' do

					get :company_followed, @id_structure
					response.status.should eq 200
					rs_followed = JSON.parse(response.body)['data']
					rs_followed.should have(2).items
					checked = 0
					rs_followed.each do |rs_f|
						@companies.each do |f|
							if f.id == rs_f['id']
								rs_f['title'].should eq f.title
								rs_f['preview_url'].should eq f.get_current_image_preview_url
								checked += 1
							end
						end
					end
					checked.should eq 2
				end

				it 'has correct rs for limit & offset' do
					get :company_followed, @id_structure.merge({limit: 1, offset: 0})
					response.status.should eq 200
					rs_followed = JSON.parse(response.body)['data']
					rs_followed.should have(1).items
					first_id = rs_followed[0]['id']

					get :company_followed, @id_structure.merge({limit: 1, offset: 1})
					response.status.should eq 200
					rs_followed = JSON.parse(response.body)['data']
					rs_followed.should have(1).items
					second_id = rs_followed[0]['id']

					first_id.should_not eq second_id
				end
			end
		end
	end
end