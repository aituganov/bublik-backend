require 'spec_helper'

describe Api::MenuController, type: :controller do

	context 'menu get' do
		it 'wrong access token has 401' do
			cookies['ACCESS_TOKEN'] = 'illegal'
			get :get
			response.status.should eq 401
		end

		it 'empty access token has anonymous' do
			get :get
			response.status.should eq 200

			rs = JSON.parse(response.body)['data']
			rs['user']['anonymous'].should be_true
			rs['menu_items'].should have(0).items
		end

		it 'valid access token has data' do
			@user = FactoryGirl.create(:user)
			cookies['ACCESS_TOKEN'] = @user.access_token
			get :get
			response.status.should eq 200

			rs = JSON.parse(response.body)['data']
			rs_user = rs['user']
			rs_user['anonymous'].should be_nil
			rs_user['id'].should eq @user.id
			rs_user['full_name'].should eq @user.full_name
			rs_user['avatar_preview_url'].should eq @user.get_current_image_preview_url
			rs['menu_items'].should_not have(0).items
		end
	end
end
