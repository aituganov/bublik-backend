class UserController < ApplicationController

	include UserHelper

	def anonymous
		render json: get_fake_anonymous_data
	end

end
