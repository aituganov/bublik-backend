require 'spec_helper'

describe Api::Company::Social::SocialController do
	describe 'routing' do
		it 'routes to #followers' do
			get('/api/company/1/social/followers').should route_to('api/company/social/social#followers', id: '1')
		end
	end
end
