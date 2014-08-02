class UsersController < ApplicationController
	include ApplicationHelper
	include UsersHelper
	skip_before_filter :verify_authenticity_token
	before_filter :check_updated, only: [:index, :update, :delete, :interests_add, :interests_delete]

	def index
		rs = rq_user.get_data({User.RS_DATA[:FULL] => true})
		render_event :ok, rs.merge(build_privileges access_token, rq_user)
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
		return unless check_privileges access_token, :update, rq_user

		unless params[:avatar].nil?
			unless avatar[:data].nil?
				rq_user.avatar = avatar[:data]
			else
				#do crop
			end
			rs_data[User.RS_DATA[:AVATAR]] = true
		end

		if rq_user.update(user_params)
			render_event :ok, rq_user.get_data(rs_data)
		else
			render_error :bad_request, rq_user.errors
		end
	end

	def delete
		return unless check_privileges access_token, :destroy, rq_user
		rq_user.destroy
		render_event :ok
	end

	def interests_add
		return unless check_privileges access_token, :update, rq_user
		begin
			rq_user.interests_add interests
			render_event :created
		rescue ActionController::ParameterMissing => e
			render_error :bad_request
		end
	end

	def interests_delete
		return unless check_privileges access_token, :update, rq_user
		begin
			rq_user.interests_delete interests
			render_event :ok
		rescue ActionController::ParameterMissing => e
			render_error :bad_request
		end
	end

	private

	def user_params
		params.permit(:id, :login, :password, :last_name, :first_name)
	end

	def interests
		params.require(:interests)
	end

	def avatar
		params.require(:avatar).permit(:data, :crop)
	end

	def check_updated
		unless User.where(id: user_params[:id]).present?
			render_error :not_found, "User ##{user_params[:id]} isn't founded"
		end
	end

	def access_token
		@access_token ||= get_access_token cookies
	end

	def rq_user
		@rq_user ||= User.find(user_params[:id])
	end

end