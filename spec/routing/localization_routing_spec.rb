require 'spec_helper'

describe Api::LocalizationController do
	describe 'routing' do
		it 'routes to #get' do
			get('/api/localization').should route_to('api/localization#get')
		end

	end
end
