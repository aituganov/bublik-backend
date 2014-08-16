require 'spec_helper'

describe Api::User::UsersController do
	describe 'routing' do

		it 'routes to #index' do
			get('/api/user/1').should route_to('api/user/users#index', id: '1')
		end

		it 'routes to #registration' do
			put('/api/user/new').should route_to('api/user/users#registration')
		end

		it 'routes to #login' do
			put('/api/user/login').should route_to('api/user/users#login')
		end

		it 'check empty login route to #page_not_found' do
			get('/api/user/login/check').should route_to('api/application#page_not_found', path: 'user/login/check')
		end

		it 'routes to #check_login' do
			get('/api/user/login/check/new@login.ru').should route_to('api/user/users#check_login', login: 'new@login.ru')
		end

		it 'routes to #update' do
			post('/api/user/1').should route_to('api/user/users#update', id: '1')
		end

		it 'routes to #delete' do
			delete('/api/user/1').should route_to('api/user/users#delete', id: '1')
		end
	end
end
