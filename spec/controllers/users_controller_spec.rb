require 'spec_helper'

describe UsersController do

	context 'GET anonymous user info' do

		it 'has a 200 response status code' do
			get :anonymous
		end

		it 'has a info for anonymous user' do
			get :anonymous
			isAnonymous = JSON.parse(response.body)['anonymous']
			isAnonymous.should be_true
		end

		it 'info for anonymous user has a menuItems' do
			get :anonymous
			menu = JSON.parse(response.body)['menuItems']
			menu.should_not be_empty
		end

		it 'info for anonymous user has a widgets' do
			get :anonymous
			menu = JSON.parse(response.body)['widgets']
			menu.should_not be_empty
		end

	end

end
