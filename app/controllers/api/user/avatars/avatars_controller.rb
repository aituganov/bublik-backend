include ApplicationHelper
include UsersHelper

class Api::User::Avatars::AvatarsController < Api::User::UsersController
	before_filter :check_user
	before_filter :check_avatar, except: [:index, :create]

	def index
		check_privileges access_token, :read, rq_user
		render_event :ok, rq_user.build_response({User.RS_DATA[:AVATARS] => true})
	end

	def create
		check_privileges access_token, :update, rq_user
		check_privileges access_token, :create, Image.new
		return unless avatar_params_valid? avatar_params

		new_avatar = rq_user.images.build avatar_params
		if new_avatar.save && new_avatar.set_current.valid?
			render_event :ok, rq_user.build_response({User.RS_DATA[:AVATAR] => true})
		else
			render_error :bad_request, rq_user.errors
		end
	end

	def set_current
		check_privileges access_token, :update, rq_user
		check_privileges access_token, :update, rq_avatar

		rs = rq_avatar.set_current
		if rs.valid?
			render_event :ok, rq_user.build_response({User.RS_DATA[:AVATAR] => true})
		else
			render_error :bad_request, rs.errors
		end
	end

	def delete
		check_privileges access_token, :update, rq_user
		check_privileges access_token, :destroy, rq_avatar

		if rq_avatar.destroy
			render_event :ok
		else
			render_error :bad_request, rq_avatar.errors
		end
	end

	private

	def avatar_params
		params.permit(:data, :content_type, :crop_x, :crop_y, :crop_l)
	end

	def rq_avatar
		@rq_avatar = Image.find(params[:avatar_id])
	end

	def check_avatar
		id = params[:avatar_id]
		logger.info "check avatar ##{id}..."
		raise ApiExceptions::NotFound::Image.new(id) unless Image.where(id: id).present?
		logger.info 'finded!'
	end

end
