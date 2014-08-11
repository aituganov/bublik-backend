require 'spec_helper'

describe Api::WidgetsController, type: :controller do

	context 'GET widgets by id' do

		it 'has a 200 status code without params' do
			get :get, id: 'top_widget'
			response.status.should eq 200
		end

		it 'check default params' do
			rq_id = 'top_widget'

			get :get, id: rq_id

			rs = JSON.parse(response.body)

			rs['id'].should eq rq_id
			rs['level'].should eq AppSettings.widgets.level_default
			rs['itemsCnt'].should eq AppSettings.widgets.limit_default
			rs['items'].should_not be_empty
			rs['items'].count.should eq AppSettings.widgets.limit_default

		end

		it 'check defined params without offset' do
			rq_id = 'top_widget'
			rq_level = 'country'
			rq_limit = 5


			get :get, id: rq_id, level: rq_level, limit: rq_limit

			rs = JSON.parse(response.body)

			response.status.should eq 200

			rs['id'].should eq rq_id
			rs['level'].should eq rq_level
			rs['itemsCnt'].should eq rq_limit
			rs['items'].should_not be_empty
			rs['items'].count.should eq rq_limit

		end

		it 'check offset' do
			rq_id = 'top_widget'
			rq_limit = 1
			rq_offset_first = 1
			rq_offset_second = 1

			get :get, id: rq_id, limit: rq_limit, offset: rq_offset_first

			response.status.should eq 200
			item_first = JSON.parse(response.body)['items'][0]

			get :get, id: rq_id, limit: rq_limit, offset: rq_offset_second

			response.status.should eq 200
			item_second = JSON.parse(response.body)['items'][0]

			item_first.should_not eq item_second

		end

	end

end
