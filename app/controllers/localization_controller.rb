class LocalizationController < ApplicationController

	before_action :set_locale

	def get
		render json: get_localization_contain
	end

	private

	def set_locale
		accept_language = request.env['HTTP_ACCEPT_LANGUAGE']
		logger.info "* Accept-Language value from header: #{accept_language}"
		@lang = accept_language ? accept_language.scan(/^[a-z]{2}/).first : AppSettings.localization.default_locale
		logger.info "Use #{@lang} locale"
		if !File.exist?(AppSettings.get_path_to_locale(@lang))
			logger.info 'file not found. use default locale'
			@lang = AppSettings.localization.default_locale
		else
			logger.info 'localization founded!'
		end
	end

	def get_localization_contain
		from_cache = Rails.cache.read("locale_#{@lang}")
		if (from_cache.nil?)
			from_cache = YAML::load(File.open(AppSettings.get_path_to_locale(@lang)))
			Rails.cache.write("locale_#{@lang}", from_cache)
		end

		from_cache
	end

end
