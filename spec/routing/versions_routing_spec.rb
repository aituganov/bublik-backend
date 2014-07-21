require 'spec_helper'

describe LocalizationController do
	describe 'routing' do
		it 'routes to #current_version' do
			get('/api/version').should route_to('versions#current_version')
		end

	end
end
