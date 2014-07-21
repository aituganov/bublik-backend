require File.expand_path('../boot', __FILE__)
#log4r requirements
require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Backend
	class Application < Rails::Application
		# Settings in config/environments/* take precedence over those specified here.
		# Application configuration should go into files in config/initializers
		# -- all .rb files in that directory are automatically loaded.
		config.autoload_paths += %W(#{config.root}/lib)

		# Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
		# Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
		# config.time_zone = 'Central Time (US & Canada)'

		# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
		# config.i18n.load_path += Dir[Rails.root.join('lib', 'locales', '*.{rb,yml}').to_s]
		# config.i18n.default_locale = :ru

		#assign log4r's logger as rails' logger.
		log4r_config= YAML.load_file(File.join(File.dirname(__FILE__),"log4r.yml"))
		log_cfg = Log4r::YamlConfigurator
		log_cfg["RAILS_ENV"] = Rails.env
		log_cfg["RAILS_ROOT"] = "#{Rails.root}"
		log_cfg.decode_yaml( log4r_config['log4r_config'] )

		config.logger = Log4r::Logger[Rails.env]

		config.generators do |g|
			g.test_framework :rspec,
				:fixtures => true,
				:view_specs => false,
				:helper_specs => true,
				:routing_specs => true,
				:controller_specs => true,
				:request_specs => true
			g.fixture_replacement :factory_girl, dir: 'spec/factories'
		end
	end
end
