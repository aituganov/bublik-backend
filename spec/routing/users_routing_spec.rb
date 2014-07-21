require 'spec_helper'

describe UsersController do
	describe 'routing' do

		it 'routes to #index' do
			get('/api/user').should route_to('users#index')
		end

		it 'routes to #registration' do
			put('/api/user/new').should route_to('users#registration')
		end

		it 'routes to #login' do
			put('/api/user/login').should route_to('users#login')
		end

		it 'check empty login route to #page_not_found' do
			get('/api/user/login/check').should route_to('application#page_not_found', path: 'api/user/login/check')
		end

		it 'routes to #check_login' do
			get('/api/user/login/check/new@login').should route_to('users#check_login', login: 'new@login')
		end

		it 'routes to #update' do
			post('/api/user').should route_to('users#update')
		end

		it 'routes to #delete' do
			delete('/api/user').should route_to('users#delete')
		end
	end
end
