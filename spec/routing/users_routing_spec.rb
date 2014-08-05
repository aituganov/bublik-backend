require 'spec_helper'

describe UsersController do
	describe 'routing' do

		it 'routes to #index' do
			get('/api/user/1').should route_to('users#index', id: '1')
		end

		it 'routes to #interests_delete' do
			get('/api/user/1/created_companies').should route_to('users#created_companies', id: '1')
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
			get('/api/user/login/check/new@login.ru').should route_to('users#check_login', login: 'new@login.ru')
		end

		it 'routes to #update' do
			post('/api/user/1').should route_to('users#update', id: '1')
		end

		it 'routes to #get_avatars' do
			get('/api/user/1/avatars').should route_to('users#get_avatars', id: '1')
		end

		it 'routes to #update_avatar' do
			post('/api/user/1/avatar').should route_to('users#create_avatar', id: '1')
		end

		it 'routes to #set_current_avatar' do
			post('/api/user/1/avatar/current/12').should route_to('users#set_current_avatar', id: '1', avatar_id: '12')
		end

		it 'routes to #set_current_avatar' do
			delete('/api/user/1/avatar/12').should route_to('users#delete_avatar', id: '1', avatar_id: '12')
		end

		it 'routes to #delete' do
			delete('/api/user/1').should route_to('users#delete', id: '1')
		end

		it 'routes to #interests_add' do
			put('/api/user/1/interests').should route_to('users#interests_add', id: '1')
		end

		it 'routes to #interests_delete' do
			delete('/api/user/1/interests').should route_to('users#interests_delete', id: '1')
		end
	end
end
