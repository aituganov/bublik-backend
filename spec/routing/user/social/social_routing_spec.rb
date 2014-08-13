require 'spec_helper'

describe Api::User::Social::SocialController do
	describe 'routing' do
		it 'routes to #user_follow' do
			post('/api/user/1/social/user/follow/12').should route_to('api/user/social/social#user_follow', id: '1', user_id: '12')
		end

		it 'routes to #user_unfollow' do
			post('/api/user/1/social/user/unfollow/12').should route_to('api/user/social/social#user_unfollow', id: '1', user_id: '12')
		end

		it 'routes to #user_followed' do
			get('/api/user/1/social/user/followed').should route_to('api/user/social/social#user_followed', id: '1')
		end

		it 'routes to #user_followers' do
			get('/api/user/1/social/user/followers').should route_to('api/user/social/social#user_followers', id: '1')
		end

		it 'routes to #company_follow' do
			post('/api/user/1/social/company/follow/12').should route_to('api/user/social/social#company_follow', id: '1', company_id: '12')
		end

		it 'routes to #company_unfollow' do
			post('/api/user/1/social/company/unfollow/12').should route_to('api/user/social/social#company_unfollow', id: '1', company_id: '12')
		end

		it 'routes to #company_followed' do
			get('/api/user/1/social/company/followed').should route_to('api/user/social/social#company_followed', id: '1')
		end
	end
end
