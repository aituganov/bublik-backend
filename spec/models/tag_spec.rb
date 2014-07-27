require 'spec_helper'

describe Tag do
	context 'check validators' do
		it 'should require a name' do
			rs = FactoryGirl.build(:tag_wrong)
			rs.should_not be_valid
			rs.should have(1).error_on(:name)
		end

		it 'login should error if name more then 100' do
			long_name = (0...101).map { ('a'..'z').to_a[rand(26)] }.join
			rs = FactoryGirl.build(:tag_wrong, name: long_name)
			rs.should_not be_valid
			rs.should have(1).error_on(:name)
		end

		it 'should ok if name less or equal then 100' do
			correct_name = (0...100).map { ('a'..'z').to_a[rand(26)] }.join
			FactoryGirl.build(:tag_first, name: correct_name).should be_valid
		end

		it 'should error if name isn\'t unique' do
			FactoryGirl.create(:tag_first).should be_valid
			rs = FactoryGirl.build(:tag_first)
			rs.should_not be_valid
			rs.should have(1).error_on(:name)
		end
	end
end
