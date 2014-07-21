class UsersController < ApplicationController
	include ApplicationHelper
	include UsersHelper
	skip_before_filter :verify_authenticity_token

	def index
		token = get_access_token
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
		respond_to do |format|
			if user.nil?
				format.json { render_error :unauthorized }
			else
				format.json { render_event :ok, {access_token: user.access_token} }
			end
		end
	end

	def check_login
		user = User.where(login: params[:login]).take
		respond_to do |format|
			if user.nil?
				format.json { render_event :ok }
			else
				format.json { render_error :created, {login: 'already registered'} }
			end
		end
	end

	def update
		user = get_user_by_access_token
		respond_to do |format|
			if user.nil?
				format.json { render_error :not_found }
			elsif user.update(user_params)
				format.json { render_event :ok }
			else
				format.json { render_error :bad_request, user.errors }
			end
		end
	end

	def delete
		user = get_user_by_access_token
		respond_to do |format|
			if user.nil?
				format.json { render_error :not_found }
			elsif user.mark_as_deleted
				format.json { render_event :ok }
			else
				format.json { render_error :bad_request, user.errors }
			end
		end
	end

	private

	def user_params
		params[:user].nil? ? {} : params.require(:user).permit(:login, :password, :last_name, :first_name)
	end

	def get_access_token
		cookies[:ACCESS_TOKEN]
	end

	def get_user_by_access_token
		User.where(access_token: get_access_token).take
	end

end
