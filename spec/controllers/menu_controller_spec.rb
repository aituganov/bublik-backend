require 'spec_helper'

describe MenuController do

	context 'menu get' do
		it 'invalid access token has 404' do
			cookies['ACCESS_TOKEN'] = 'illegal'
			get :get
			response.status.should eq 404
		end

		it 'empty access token has anonymous' do
			get :get
			response.status.should eq 200

			rs = JSON.parse(response.body)['data']
			rs['anonymous'].should be_true
			rs['menu'].should have(0).items
		end

		it 'valid access token has data' do
			cookies['ACCESS_TOKEN'] = FactoryGirl.create(:user).access_token
			get :get
			response.status.should eq 200

			rs = JSON.parse(response.body)['data']
			rs['anonymous'].should be_nil
			rs['menu'].should_not have(0).items
		end
	end
end
