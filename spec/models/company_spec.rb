require 'spec_helper'
include TestHelper

describe Company do
	before :each do
		@correct_user = FactoryGirl.create(:user)
	end
	context 'check validators' do
		it 'should require owner & title' do
			company = FactoryGirl.build(:company, title: '')
			company.should_not be_valid
			company.should have(1).error_on(:owner)
			company.should have(1).error_on(:title)
		end

		it 'should require owner' do
			company = FactoryGirl.build(:company)
			company.should_not be_valid
			company.should have(1).error_on(:owner)
		end

		it 'should require title' do
			company = FactoryGirl.build(:company, owner: @correct_user, title: '')
			company.should_not be_valid
			company.should have(1).error_on(:title)
		end

		it 'should require title less than 50' do
			company = FactoryGirl.build(:company, owner: @correct_user, title: generate_random_string(51))
			company.should_not be_valid
			company.should have(1).error_on(:title)
		end

		it 'should ok for title less or eq than 50' do
			FactoryGirl.build(:company, owner: @correct_user, title: generate_random_string(50)).should be_valid
		end

		it 'should require slogan less than 50' do
			company = FactoryGirl.build(:company, owner: @correct_user, slogan: generate_random_string(51))
			company.should_not be_valid
			company.should have(1).error_on(:slogan)
		end

		it 'should ok for slogan less or eq than 50' do
			FactoryGirl.build(:company, owner: @correct_user, slogan: generate_random_string(50)).should be_valid
		end

		it 'should require description less than 500' do
			company = FactoryGirl.build(:company, owner: @correct_user, description: generate_random_string(501))
			company.should_not be_valid
			company.should have(1).error_on(:description)
		end

		it 'should ok for description less or eq than 500' do
			FactoryGirl.build(:company, owner: @correct_user, description: generate_random_string(500)).should be_valid
		end

		it 'should require rating more or eq than 0' do
			company = FactoryGirl.build(:company, owner: @correct_user, rating: -0.1)
			company.should_not be_valid
			company.should have(1).error_on(:rating)
		end

		it 'should ok for rating eq 0' do
			FactoryGirl.build(:company, owner: @correct_user, rating: 0).should be_valid
		end

		it 'should require rating less or eq than 5' do
			company = FactoryGirl.build(:company, owner: @correct_user, rating: 5.1)
			company.should_not be_valid
			company.should have(1).error_on(:rating)
		end

		it 'should ok for rating eq 5' do
			FactoryGirl.build(:company, owner: @correct_user, rating: 5).should be_valid
		end

		it 'should ok for rating between -' do
			FactoryGirl.build(:company, owner: @correct_user, rating: 5).should be_valid
		end
	end

	context 'update tags' do
		before(:each) do
			@created_company = FactoryGirl.create(:company, owner: @correct_user, rating: 5)
			@created_company.should be_valid
		end

		it 'add new tags to the company' do
			@created_company.tag_list.add(['first', 'second'])
			@created_company.save
			@created_company.tag_list.should have(2).item
			@created_company.tags.should have(2).item
			Tag.all.should have(2).item
		end

		it 'check tags uniq' do
			@created_company.tag_list.add(['first', 'first'])
			@created_company.save
			@created_company.tag_list.should have(1).item
			@created_company.tags.should have(1).item
			Tag.all.should have(1).item
		end

		it 'add existed tags to company' do
			@created_company.tag_list.add(['first', 'second'])
			@created_company.save
			@created_company.tag_list.should have(2).item
			@created_company.tags.should have(2).item

			second_company = FactoryGirl.create(:company_second, owner: @correct_user)
			second_company.should be_valid
			second_company.tag_list.add(['second', 'third'])
			second_company.save
			second_company.tag_list.should have(2).item
			second_company.tags.should have(2).item

			Tag.all.should have(3).item
		end

		it 'check tags remove' do
			@created_company.tag_list.add(['first', 'second'])
			@created_company.save
			@created_company.tag_list.should have(2).item
			@created_company.tags.should have(2).item
			Tag.all.should have(2).item

			@created_company.tag_list.remove(['first', 'second'])
			@created_company.save
			@created_company.tag_list.should have(0).item
			@created_company.tags.should have(0).item
			Tag.all.should have(2).item
		end

		it 'check remove unexisted tags' do
			@created_company.tag_list.add(['first', 'second'])
			@created_company.save
			@created_company.tag_list.should have(2).item
			@created_company.tags.should have(2).item
			Tag.all.should have(2).item

			@created_company.tag_list.remove(['third', 'fourth'])
			@created_company.save
			@created_company.tag_list.should have(2).item
			@created_company.tags.should have(2).item
			Tag.all.should have(2).item
		end
	end
end
