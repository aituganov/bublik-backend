class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

	def page_not_found
		render  text: 'Requested resource not found', status: 404, layout: false
		#render  status: 404, :layout => true
	end

end
