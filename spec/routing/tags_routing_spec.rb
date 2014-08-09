require 'spec_helper'

describe Api::TagsController do
	describe 'routing' do

		it 'routes to #find' do
			get('api/tag/tag%20name').should route_to('api/tags#find', name: 'tag name')
		end

		it 'routes to #find with limit' do
			get('api/tag/tag%20name?limit=20').should route_to('api/tags#find', name: 'tag name', limit: '20')
		end
	end
end
