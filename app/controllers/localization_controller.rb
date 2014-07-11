class LocalizationController < ApplicationController

	before_action :set_locale

	def get
		render json: get_localization_contain
	end

	private

	def set_locale
		accept_language = request.env['HTTP_ACCEPT_LANGUAGE']
		puts "* Accept-Language: #{accept_language}"
		@lang = accept_language ? accept_language.scan(/^[a-z]{2}/).first : AppSettings.localization.default_locale
		if !File.exist?(make_localization_path)
			puts 'file not found. use default locale'
			@lang = AppSettings.localization.default_locale
		end
		puts "* Locale set to '#{@lang}'"
	end

	def get_localization_contain
		YAML::load(File.open(make_localization_path))
	end

	def make_localization_path
		"#{AppSettings.localization.directory}#{@lang}.yml"
	end

end
