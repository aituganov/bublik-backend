require 'spec_helper'

describe Api::User::Avatars::AvatarsController do
	describe 'routing' do
		it 'routes to #get_avatars' do
			get('/api/user/1/avatars').should route_to('api/user/avatars/avatars#index', id: '1')
		end

		it 'routes to #update_avatar' do
			post('/api/user/1/avatar').should route_to('api/user/avatars/avatars#create', id: '1')
		end

		it 'routes to #set_current_avatar' do
			post('/api/user/1/avatar/current/12').should route_to('api/user/avatars/avatars#set_current', id: '1', avatar_id: '12')
		end

		it 'routes to #delete_avatar' do
			delete('/api/user/1/avatar/12').should route_to('api/user/avatars/avatars#delete', id: '1', avatar_id: '12')
		end
	end
end
