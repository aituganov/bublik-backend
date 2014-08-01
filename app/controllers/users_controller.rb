class UsersController < ApplicationController
	include ApplicationHelper
	include UsersHelper
	skip_before_filter :verify_authenticity_token
	before_filter :get_user, only: [:update, :delete, :interests_add, :interests_delete]

	def index
		token = get_access_token(cookies)
		if token.nil?
			render json: get_fake_anonymous_data
		else
			return unless get_user
			render_event :ok, @user.get_data({User.RS_DATA[:FULL] => true})
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
		rs_data = {}

		unless params[:avatar].nil?
			unless avatar[:data].nil?
				@user.avatar = avatar[:data]
			else
				#do crop
			end
			rs_data[User.RS_DATA[:AVATAR]] = true
		end

		if @user.update(user_params)
			render_event :ok, @user.get_data(rs_data)
		else
			render_error :bad_request, @user.errors
		end
	end

	def delete
		if @user.destroy
			render_event :ok
		else
			render_error :bad_request, @user.errors
		end
	end

	def interests_add
		begin
			@user.interests_add interests
			render_event :created
		rescue ActionController::ParameterMissing => e
			render_error :bad_request
		end
	end

	def interests_delete
		begin
			@user.interests_delete interests
			render_event :ok
		rescue ActionController::ParameterMissing => e
			render_error :bad_request
		end
	end

	private

	def get_user
		res = true
		@user = get_user_by_access_token cookies
		if @user.nil?
			head :not_found
			res = false
		end
		res
	end

	def user_params
		params.permit(:login, :password, :last_name, :first_name)
	end

	def interests
		params.require(:interests)
	end

	def avatar
		params.require(:avatar).permit(:data, :crop)
	end

end
