require 'spec_helper'

describe Api::VersionsController do

	describe 'GET version' do
		it 'has a 200 status code' do
			get :current_version
			response.status.should eq 200
		end

		it 'has correct version' do
			version_contain = File.open("#{Rails.root}/version", &:readline)
			get :current_version
			response.body.should eq version_contain
		end

	end

end
