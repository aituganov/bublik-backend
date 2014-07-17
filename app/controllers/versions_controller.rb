class VersionsController < ApplicationController

	before_action :load_version_file

	def current_version
		render text: @version
	end

	private
	def load_version_file
		@version = Rails.cache.read('app_version')
		if (@version.nil?)
			logger.info 'Get version from file...'
			@version = File.open("#{Rails.root}/version", &:readline)
			Rails.cache.write('app_version', @version)
		else
			logger.info 'Take app version from cache'
		end
	end

end