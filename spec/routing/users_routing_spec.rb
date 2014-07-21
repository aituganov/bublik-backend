# require 'spec_helper'
#
# describe UsersController do
# 	describe 'routing' do
#
# 		it 'routes to #index' do
# 			expect(get: '/api/user').to route_to('users#index')
# 			# get('/api/user').to route_to('users#index')
# 		end
#
# 		it 'routes to #registration' do
# 			get('/api/user/new').should route_to('users#registration')
# 		end
#
# 		it 'routes to #login' do
# 			get('/api/user/login').should route_to('users#login')
# 		end
#
# 		it 'routes to #update' do
# 			post('/api/user').should route_to('users#update')
# 			put('/api/user').should route_to('users#update')
# 		end
#
# 		it 'routes to #delete' do
# 			delete('/api/user').should route_to('users#delete')
# 		end
# 	end
# end
