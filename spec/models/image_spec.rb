require 'spec_helper'

describe Image do
	context 'check validators' do
		it 'should require a preview_url' do
			FactoryGirl.build(:image, preview_url: '').should_not be_valid
			FactoryGirl.build(:image, preview_url: '').should have(1).error_on(:preview_url)
		end

		it 'should ok if a fullsize_url isn\'t defined' do
			FactoryGirl.build(:image, fullsize_url: '').should be_valid
		end

		it 'should ok if both url defined' do
			FactoryGirl.build(:image).should be_valid
		end
	end
end
