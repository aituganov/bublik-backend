require 'spec_helper'

describe Api::Search::TagsController, type: :controller do
	before :each do
		cookies['ACCESS_TOKEN'] = FactoryGirl.create(:user).access_token
		@correct_name = 'Correct name'
		@tag_first = FactoryGirl.build(:tag_first)
	end

	context 'tag find' do
		it 'has 200 & empty rs data for unexist name' do
			post :find, name: 'Test'
			response.status.should eq 200
			JSON.parse(response.body)['data']['tags'].should be_empty
		end

		it 'has 200 & correct rs data for exist name' do
			FactoryGirl.create(:tag_first).should be_valid
			FactoryGirl.create(:tag_second).should be_valid
			post :find, name: @tag_first.name
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
			post :find, name: 'FIRST'
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
			post :find, name: 'tag'
			response.status.should eq 200
			rs_tag = JSON.parse(response.body)['data']['tags']
			rs_tag.should have(3).items
		end

		it 'has 200 & correct rs data only for 1 tag' do
			FactoryGirl.create(:tag_first).should be_valid
			FactoryGirl.create(:tag_second).should be_valid
			FactoryGirl.create(:tag_third).should be_valid
			post :find, name: 'Second'
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

			post :find, name: 'tag'
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

			post :find, name: 'tag', limit: defined_limit
			response.status.should eq 200
			rs_tag = JSON.parse(response.body)['data']['tags']
			rs_tag.should have(defined_limit).items
		end
	end

	context 'find with exclude' do
		before(:each) do
			@first = FactoryGirl.create(:tag_first)
			@first.should be_valid
			@second = FactoryGirl.create(:tag_second)
			@second.should be_valid
			@third = FactoryGirl.create(:tag_third)
			@third.should be_valid
		end

		it 'has 200 & all tags with invalid excluded format' do
			post :find, name: 'tag', exclude: @first.name
			response.status.should eq 200
			rs_tag = JSON.parse(response.body)['data']['tags']
			rs_tag.should have(3).items
		end

		it 'has 200 & correct rs data for exist name & exclude' do
			post :find, name: 'tag', exclude: [@first.name]
			response.status.should eq 200
			rs_tag = JSON.parse(response.body)['data']['tags']
			rs_tag.should have(2).items
			rs_tag.each do |t|
				t['name'].should_not eq @first.name
			end
		end

		it 'has 200 & correct rs data for exist name & exclude' do
			post :find, name: 'tag', exclude: [@first.name, @second.name]
			response.status.should eq 200
			rs_tag = JSON.parse(response.body)['data']['tags']
			rs_tag.should have(1).items
			rs_tag.each do |t|
				t['name'].should_not eq @first.name
				t['name'].should_not eq @second.name
			end
		end

		it 'check defined limit' do
			post :find, name: 'tag', exclude: [@first.name], limit: 1
			response.status.should eq 200
			rs_tag = JSON.parse(response.body)['data']['tags']
			rs_tag.should have(1).items
			first = rs_tag[0]
			first['name'].should_not eq @first.name
		end

	end
end
