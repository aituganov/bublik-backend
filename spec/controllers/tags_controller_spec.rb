require 'spec_helper'

describe TagsController do
	before :each do
		cookies['ACCESS_TOKEN'] = FactoryGirl.create(:user).access_token
		@correct_name = 'Correct name'
		@tag_first = FactoryGirl.build(:tag_first)
	end

	context 'tag create' do
		it 'has 404 error for empty access token' do
			cookies['ACCESS_TOKEN'] = ''
			put :new
			response.status.should eq 404
		end

		it 'has 409 for not unique name' do
			FactoryGirl.create(:tag_first).should be_valid
			put :new, @tag_first.name
			response.status.should eq 409
		end

		it 'has 201 for correct tag param' do
			put :new, name: @correct_name
			response.status.should eq 201
		end

		it 'has 201 with correct response data' do
			put :new, name: @correct_name
			response.status.should eq 201
			rs_tag = JSON.parse(response.body)['data']['tag']
			rs_tag.should_not be_nil
			rs_tag['id'].should_not be_nil
			rs_tag['name'].should eq @correct_name
		end
	end

	context 'tag find' do
		it 'has 404 error for empty access token' do
			cookies['ACCESS_TOKEN'] = ''
			get :find, name: ''
			response.status.should eq 404
		end

		it 'has 200 & empty rs data for unexist name' do
			get :find, name: 'Test'
			response.status.should eq 200
			JSON.parse(response.body)['data']['tags'].should be_empty
		end

		it 'has 200 & correct rs data for exist name' do
			FactoryGirl.create(:tag_first)
			FactoryGirl.create(:tag_second).should be_valid
			get :find, name: @tag_first.name
			response.status.should eq 200
			rs_tag = JSON.parse(response.body)['data']['tags']
			rs_tag.should have(1).items
			tag = rs_tag[0]
			tag['id'].should_not be_nil
			tag['name'].should_not be_nil
			tag['name'].should eq @tag_first.name
		end

		it 'has 200 & correct rs data & ignore case' do
			t = FactoryGirl.create(:tag_first)
			t.should be_valid
			FactoryGirl.create(:tag_second).should be_valid
			get :find, name: 'FIRST'
			response.status.should eq 200
			rs_tag = JSON.parse(response.body)['data']['tags']
			rs_tag.should have(1).items
			tag = rs_tag[0]
			tag['id'].should_not be_nil
			tag['name'].should_not be_nil
		end

		it 'has 200 & correct rs data for 3 tags' do
			FactoryGirl.create(:tag_first).should be_valid
			FactoryGirl.create(:tag_second).should be_valid
			FactoryGirl.create(:tag_third).should be_valid
			get :find, name: 'tag'
			response.status.should eq 200
			rs_tag = JSON.parse(response.body)['data']['tags']
			rs_tag.should have(3).items
		end

		it 'has 200 & correct rs data only for 1 tag' do
			FactoryGirl.create(:tag_first).should be_valid
			FactoryGirl.create(:tag_second).should be_valid
			FactoryGirl.create(:tag_third).should be_valid
			get :find, name: 'Second'
			response.status.should eq 200
			rs_tag = JSON.parse(response.body)['data']['tags']
			rs_tag.should have(1).items
		end

		it 'check default limit' do
			def_limit = AppSettings.limit_default
			(def_limit + 1).times do |i|
				name = "#{i} tag"
				FactoryGirl.create(:tag_first, name: name).should be_valid
			end

			get :find, name: 'tag'
			response.status.should eq 200
			rs_tag = JSON.parse(response.body)['data']['tags']
			rs_tag.should have(def_limit).items
		end

		it 'check defined limit' do
			defined_limit = 1
			(defined_limit + 1).times do |i|
				name = "#{i} tag"
				FactoryGirl.create(:tag_first, name: name).should be_valid
			end

			get :find, name: 'tag', limit: defined_limit
			response.status.should eq 200
			rs_tag = JSON.parse(response.body)['data']['tags']
			rs_tag.should have(defined_limit).items
		end
	end
end