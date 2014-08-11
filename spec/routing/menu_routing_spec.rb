require 'spec_helper'

describe Api::MenuController do
	describe 'routing' do
		it 'routes to #get' do
			get('api/menu').should route_to('api/menu#get')
		end
	end
end
