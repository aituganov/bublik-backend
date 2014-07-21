require 'spec_helper'

describe LocalizationController do
	describe 'routing' do
		it 'routes to #get' do
			get('/api/localization').should route_to('localization#get')
		end

	end
end
