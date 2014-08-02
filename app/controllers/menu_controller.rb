include ApplicationHelper

class MenuController < ApplicationController

	def get
		token = get_access_token cookies
		user = get_user_by_access_token token
		if get_access_token(cookies).nil?
			render_event :ok, {anonymous: true, menu: []}
		elsif user.nil?
			render_error :not_found
		else
			render_event :ok, user.get_menu
		end
	end

end
