require 'spec_helper'

describe Api::LocalizationController do
	describe 'routing' do
		it 'routes to #current_version' do
			get('/api/version').should route_to('api/versions#current_version')
		end

	end
end
