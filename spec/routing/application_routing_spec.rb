require 'spec_helper'

describe ApplicationController do
	describe 'routing' do
		it 'routes to #get' do
			get('/strange/path').should route_to('application#page_not_found', path:'strange/path')
		end
	end
end
