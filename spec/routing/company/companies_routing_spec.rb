require 'spec_helper'

describe Api::Company::CompaniesController do
	describe 'routing' do
		it 'routes to #new' do
			put('/api/company/new').should route_to('api/company/companies#registration')
		end

		it 'routes to #get' do
			get('/api/company/1').should route_to('api/company/companies#index', id: '1')
		end

		it 'routes to #update' do
			post('/api/company/1').should route_to('api/company/companies#update', id: '1')
		end

		it 'routes to #delete' do
			delete('/api/company/1').should route_to('api/company/companies#delete', id: '1')
		end
	end
end
