require 'spec_helper'
include CarrierWave::Test::Matchers

describe Image do
	context 'check model validators' do
		it 'data not nil' do
			image = FactoryGirl.build(:image_wrong)
			image.should_not be_valid
			image.should have(1).error_on(:data)
		end

		it 'content_type not nil' do
			image = FactoryGirl.build(:image_wrong)
			image.should_not be_valid
			image.should have(1).error_on(:content_type)
		end

		it 'crop_x >= 0' do
			expect { FactoryGirl.create(:image, crop_x: -1) }.to raise_error(ArgumentError)
			FactoryGirl.create(:image, crop_x: 0).should be_valid
		end

		it 'crop_y >= 0' do
			expect { FactoryGirl.create(:image, crop_y: -1) }.to raise_error(ArgumentError)
			FactoryGirl.create(:image, crop_y: 0).should be_valid
		end

		it 'crop_l >= 10' do
			expect { FactoryGirl.create(:image, crop_l: 9) }.to raise_error(ArgumentError)
			FactoryGirl.create(:image, crop_l: 10).should be_valid
		end
	end

	context 'check created image' do
		before do
			@user = FactoryGirl.create(:user)
			@user.should be_valid
			@created_image = @user.images.build(FactoryGirl.build(:image_hash))
			@created_image.should be_valid
			@user.save.should be_true

			@created_image.file.should_not be_nil
			@created_image.file.preview.should_not be_nil
		end

		it 'correct urls' do
			@created_image.should_not be_nil
			@created_image.imageable.should eq @user
		end

		it 'correct urls' do
			File.exist?("#{AppSettings.images.dir}#{@created_image.file.url}").should be_true
			File.exist?("#{AppSettings.images.dir}#{@created_image.file.preview.url}").should be_true
		end

		it 'correct image file' do
			@created_image.file.read.should eq File.open("#{Rails.root}/spec/fixtures/images/test.jpg", 'rb').read
		end

		it 'correct current images' do
			@created_image.set_current
			@user.get_current_image.should eq @created_image
		end

		it 'correct preview images' do
			@created_image.file.preview.should have_dimensions(AppSettings.images.preview_size, AppSettings.images.preview_size)
		end

		it 'build response' do
			data = @created_image.build_response
			data[:id].should eq @created_image.id
			data[:current].should eq @created_image.current
			data[:fullsize_url].should eq @created_image.file.url
			data[:preview_url].should eq @created_image.file.preview.url
		end

		it 'set current && uncurrent' do
			@created_image.set_current.should be_true
			@user.reload
			@created_image.current.should be_true
			@user.get_current_image.should eq @created_image

			@created_image.set_uncurrent.should be_true
			@user.reload
			@created_image.current.should be_false
			@user.get_current_image.should be_nil
		end
	end
end
