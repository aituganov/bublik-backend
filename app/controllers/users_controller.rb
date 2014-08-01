class UsersController < ApplicationController
	include ApplicationHelper
	include UsersHelper
	skip_before_filter :verify_authenticity_token
	before_filter :check_privileges, only: [:update, :interests_add, :interests_delete, :delete]

	def index
		# check self
		get_user(false)

		begin
			@requested_user = User.find(user_params[:id])
			render_event :ok, @requested_user.get_data({User.RS_DATA[:FULL] => true}, @is_self)
		rescue  ActiveRecord::RecordNotFound => e
			render_error :not_found
		end
	end

	def registration
		user = User.new(user_params)
		if user.save
			render_event :created, {id: user.id, access_token: user.access_token}
		else
			render_error :unprocessable_entity, user.errors
		end
	end

	def login
		user = User.where(user_params).take
		if user.nil?
			render_error :unauthorized
		else
			render_event :ok, {id: user.id, access_token: user.access_token}
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
		@user.destroy
		render_event :ok
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

	def get_user(generate_error=true)
		res = false
		@user = get_user_by_access_token cookies
		if @user.nil? && generate_error
			head :not_found
		elsif @user.nil?
			@is_self = false
		else
			@is_self = @user.id == user_params[:id].to_i
			res = true
		end
		res
	end

	def check_privileges
		res = false

		return res unless get_user

		if !@is_self
			head :forbidden
		else
			res = true
		end
		res
	end

	def user_params
		params.permit(:id, :login, :password, :last_name, :first_name)
	end

	def interests
		params.require(:interests)
	end

	def avatar
		params.require(:avatar).permit(:data, :crop)
	end

end
