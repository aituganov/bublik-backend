require 'spec_helper'

describe Api::User::Companies::CreatedCompaniesController do
	describe 'routing' do
		it 'routes to #index' do
			get('/api/user/1/created_companies').should route_to('api/user/companies/created_companies#index', id: '1')
		end
	end
end
