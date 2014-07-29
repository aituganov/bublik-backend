class UsersController < ApplicationController
	include ApplicationHelper
	include UsersHelper
	skip_before_filter :verify_authenticity_token

	def index
		token = get_access_token(cookies)
		if token.nil?
			render json: get_fake_anonymous_data
		else
			data = User.get_data(token)
			if data.nil?
				render_error :not_found
			else
				render_event :ok, data
			end
		end
	end

	def registration
		user = User.new(user_params)
		if user.save
			render_event :created, {access_token: user.access_token}
		else
			render_error :unprocessable_entity, user.errors
		end
	end

	def login
		user = User.where(user_params).take
		if user.nil?
			render_error :unauthorized
		else
			render_event :ok, {access_token: user.access_token}
		end
	end

	def check_login
		user = User.where(login: user_params[:login]).take
		if user.nil?
			render_event :ok
		else
			render_event :created
		end
	end

	def update
		user = get_user_by_access_token(cookies)
		if user.nil?
			render_error :not_found
			return
		end

		if !params[:interests].nil?
			interests_errors = user.set_interests interests
		end
		if interests_errors && interests_errors.count > 0
			render_error :bad_request, interests_errors
		elsif user.update(user_params)
			render_event :ok
		else
			render_error :bad_request, user.errors
		end
	end

	def delete
		user = get_user_by_access_token(cookies)
		if user.nil?
			render_error :not_found
		elsif user.mark_as_deleted
			render_event :ok
		else
			render_error :bad_request, user.errors
		end
	end

	private

	def user_params
		params.permit(:login, :password, :last_name, :first_name)
	end

	def interests
		params.require(:interests)
	end

end
