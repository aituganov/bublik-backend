require 'spec_helper'

describe WidgetsController do

	context 'GET widgets by id' do

		it 'has a 400 status code without params' do
			get :get, {id: 'top_widget'}
			response.status.should eq 400
		end
		#
		# it 'has a 200 response status code with all params' do
		# 	get :get, id: 'top_widget', :query => '?level=level&offset=1'
		# 	puts response.body.to_s
		# 	response.status.should eq 200
		# end


	end

end
