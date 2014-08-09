require 'spec_helper'

describe Api::LocalizationController do
	before :each do
		@def_locale = AppSettings.localization.default
	end

	context 'GET localization' do
		it 'has a 200 status code' do
			get :get
			response.status.should eq 200
		end

		it 'has default localization' do
			def_contain = YAML::load(File.open(AppSettings.get_path_to_locale(@def_locale))).to_json
			get :get
			response.body.should eq def_contain
		end

		it 'has default localization for unexisted file' do
			locale = 'kk'
			def_contain = YAML::load(File.open(AppSettings.get_path_to_locale(@def_locale))).to_json
			request.headers['HTTP_ACCEPT_LANGUAGE'] = locale
			get :get
			response.body.should eq def_contain
		end

		it 'has defined localization' do
			locale = 'ru'
			def_contain = YAML::load(File.open(AppSettings.get_path_to_locale(locale))).to_json
			request.headers['HTTP_ACCEPT_LANGUAGE'] = locale
			get :get
			response.body.should eq def_contain
		end
	end


end