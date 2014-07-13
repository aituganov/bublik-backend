class UsersController < ApplicationController

	include UsersHelper

	def anonymous
		render json: get_fake_anonymous_data
	end

end
