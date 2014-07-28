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
		it 'add new interests to the user' do
			tag_first = FactoryGirl.build(:tag_first)
			tag_second = FactoryGirl.build(:tag_second)
			@created_company.company_tags.create(tag: tag_first).should be_valid
			@created_company.company_tags.create(tag: tag_second).should be_valid
			@created_company.company_tags.should have(2).item
			Tag.all.should have(2).item
		end

		it 'check interests uniq' do
			tag_first = FactoryGirl.build(:tag_first)
			@created_company.company_tags.create(tag: tag_first).should be_valid
			expect{@created_company.company_tags.create(tag: tag_first)}.to raise_error(ActiveRecord::RecordNotUnique)
			@created_company.company_tags.should have(1).item
			Tag.all.should have(1).item
		end

		it 'link existed interests to the user' do
			tag_first = FactoryGirl.create(:tag_first)
			tag_second = FactoryGirl.create(:tag_second)
			tag_first.should be_valid
			tag_second.should be_valid
			@created_company.company_tags.create(tag_id: tag_first.id).should be_valid
			@created_company.company_tags.create(tag_id: tag_second.id).should be_valid
			@created_company.company_tags.should have(2).item
			@created_company.company_tags[0].tag_id.should eq tag_first.id
			@created_company.company_tags[1].tag_id.should eq tag_second.id
		end
	end
end
