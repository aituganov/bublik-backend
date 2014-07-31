require 'spec_helper'

describe CompaniesController do
	describe 'routing' do
		it 'routes to #new' do
			put('/api/company/new').should route_to('companies#registration')
		end

		it 'routes to #get' do
			get('/api/company/1').should route_to('companies#get', id: '1')
		end

		it 'routes to #update' do
			post('/api/company/1').should route_to('companies#update', id: '1')
		end

		it 'routes to #delete' do
			delete('/api/company/1').should route_to('companies#delete', id: '1')
		end

		it 'routes to #tags_add' do
			put('/api/company/1/tags').should route_to('companies#tags_add', id: '1')
		end

		it 'routes to #interests_delete' do
			delete('/api/company/1/tags').should route_to('companies#tags_delete', id: '1')
		end
	end
end
