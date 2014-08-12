require 'spec_helper'

describe Api::Company::Logotypes::LogotypesController do
	describe 'routing' do
		it 'routes to #get_logotypes' do
			get('/api/company/1/logotypes').should route_to('api/company/logotypes/logotypes#index', id: '1')
		end

		it 'routes to #update_logotype' do
			post('/api/company/1/logotype').should route_to('api/company/logotypes/logotypes#create', id: '1')
		end

		it 'routes to #set_current_logotype' do
			post('/api/company/1/logotype/current/12').should route_to('api/company/logotypes/logotypes#set_current', id: '1', logo_id: '12')
		end

		it 'routes to #delete_logotype' do
			delete('/api/company/1/logotype/12').should route_to('api/company/logotypes/logotypes#delete', id: '1', logo_id: '12')
		end
	end
end
