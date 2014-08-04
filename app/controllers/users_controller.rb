include ApplicationHelper
include AppUtils
include UsersHelper

class UsersController < ApplicationController
	skip_before_filter :verify_authenticity_token
	before_filter :check_updated, only: [:index, :created_companies, :update, :delete, :interests_add, :interests_delete]

	def index
		render_event :ok, rq_user.build_response({User.RS_DATA[:FULL] => true}, {access_token: access_token, limit: user_params[:company_limit]})
	end

	def created_companies
		render_event :ok, rq_user.build_response({User.RS_DATA[:CREATED_COMPANIES] => true}, {access_token: access_token, offset: user_params[:company_offset], limit: user_params[:company_limit]})
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
		return unless check_privileges access_token, :update, rq_user

		if rq_user.update(user_params)
			render_event :ok, rq_user.build_response(rs_data)
		else
			render_error :bad_request, rq_user.errors
		end
	end

	def update_avatar
		return unless check_privileges access_token, :update, rq_user
		return unless avatar_params_valid? avatar

		begin
			rq_user.avatar = create_tmp_image avatar[:data], avatar[:content_type]
			rq_user.crop_x = avatar[:crop_x]
			rq_user.crop_y = avatar[:crop_y]
			rq_user.crop_l = avatar[:crop_l]
			if rq_user.save
				render_event :ok, rq_user.build_response({User.RS_DATA[:AVATAR] => true})
			else
				render_error :bad_request, rq_user.errors
			end
		rescue Exception => e
			log_exception e
			render_error :bad_request
		ensure
			clear_tmp_file
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
		params.permit(:login, :password, :last_name, :first_name, :company_limit, :company_offset)
	end

	def interests
		params.require(:interests)
	end

	def avatar
		params.permit(:data, :content_type, :crop_x, :crop_y, :crop_l)
	end

	def check_updated
		unless User.where(id: params[:id]).present?
			render_error :not_found, "User ##{user_params[:id]} isn't founded"
		end
	end

	def access_token
		@access_token ||= get_access_token cookies
	end

	def rq_user
		@rq_user ||= User.find(params[:id])
	end

end
