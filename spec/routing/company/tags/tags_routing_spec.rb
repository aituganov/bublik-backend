require 'spec_helper'

describe Api::Company::Tags::TagsController do
	describe 'routing' do
		it 'routes to #tags_add' do
			put('/api/company/1/tags').should route_to('api/company/tags/tags#add', id: '1')
		end

		it 'routes to #interests_delete' do
			delete('/api/company/1/tags').should route_to('api/company/tags/tags#delete', id: '1')
		end
	end
end
