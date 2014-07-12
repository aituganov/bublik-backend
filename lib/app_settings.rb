class AppSettings < Settingslogic
	source "#{Rails.root}/config/app_settings.yml"
	namespace Rails.env

	def self.get_path_to_locale(lang)
		"#{Rails.root}/#{self.localization.directory}#{lang}.yml"
	end

end