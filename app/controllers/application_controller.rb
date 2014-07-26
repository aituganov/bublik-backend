class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

	def page_not_found
		respond_to do |format|
			format.html {render html: 'Requested resource not found', status: :not_found, layout: false}
		end
	end

	def get_access_token(cookies)
		cookies[:ACCESS_TOKEN]
	end

	def get_user_by_access_token(cookies)
		User.where(access_token: get_access_token(cookies)).take
	end

end
