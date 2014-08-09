require 'spec_helper'

describe Api::User::Interests::InterestsController do
	describe 'routing' do
		it 'routes to #interests_add' do
			put('/api/user/1/interests').should route_to('api/user/interests/interests#add', id: '1')
		end

		it 'routes to #interests_delete' do
			delete('/api/user/1/interests').should route_to('api/user/interests/interests#delete', id: '1')
		end
	end
end
