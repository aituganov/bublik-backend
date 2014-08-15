class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :log_start

	def page_not_found
		render html: 'Requested resource not found', status: :not_found, layout: false
	end

	private

	def log_start
		logger.info "Start #{self.class.name}##{self.action_name} action"
	end

end
