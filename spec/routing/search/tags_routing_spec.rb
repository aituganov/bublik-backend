require 'spec_helper'

describe Api::Search::TagsController do
	describe 'routing' do

		it 'routes to #find' do
			post('api/search/tag/tag%20name').should route_to('api/search/tags#find', name: 'tag name')
		end

		it 'routes to #find with limit' do
			post('api/search/tag/tag%20name?limit=20').should route_to('api/search/tags#find', name: 'tag name', limit: '20')
		end
	end
end
