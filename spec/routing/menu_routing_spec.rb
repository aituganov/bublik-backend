require 'spec_helper'

describe MenuController do
	describe 'routing' do
		it 'routes to #get' do
			get('api/menu').should route_to('menu#get')
		end
	end
end
