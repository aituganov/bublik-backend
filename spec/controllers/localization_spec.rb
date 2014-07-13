require 'spec_helper'

RSpec.describe LocalizationController, type: :controller do

	describe 'GET localization' do
		it 'has a 200 status code' do
			get :get
			expect(response.status).to eq(200)
		end

		it 'has default localization' do
			def_locale = AppSettings.localization.default
			def_contain = YAML::load(File.open(AppSettings.get_path_to_locale(def_locale))).to_json
			get :get
			expect(response.body).to eq(def_contain)
		end

		it 'has defined localization' do
			locale = 'ru'
			def_contain = YAML::load(File.open(AppSettings.get_path_to_locale(locale))).to_json
			request.headers["HTTP_ACCEPT_LANGUAGE"] = locale
			get :get
			expect(response.body).to eq(def_contain)
		end
	end


end