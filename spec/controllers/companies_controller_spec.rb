require 'spec_helper'

describe CompaniesController do

	context 'GET company info' do

		it 'has a 200 response status code' do
			get 'get', {id: 1}
			response.status.should eq 200
		end

		it 'has a info for requested company' do
			id = 1
			get 'get', {id: id}
			rs_id = JSON.parse(response.body)['id'].to_i
			rs_id.should eq id
		end

	end

end
