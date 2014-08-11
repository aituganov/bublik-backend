include ApplicationHelper
include UsersHelper

class Api::User::Avatars::AvatarsController < Api::User::UsersController
	before_filter :check_avatar, only: [:set_current, :delete]

	def index
		check_privileges @access_token, :read, @rq_user
		render_event :ok, @rq_user.build_response({User.RS_DATA[:AVATARS] => true})
	end

	def create
		check_privileges @access_token, :update, @rq_user
		check_privileges @access_token, :create, Image.new
		avatar_params_valid? avatar_params

		new_avatar = @rq_user.images.build avatar_params
		new_avatar.save! && new_avatar.set_current
		render_event :ok, @rq_user.build_response({User.RS_DATA[:AVATAR] => true})
	end

	def set_current
		check_privileges @access_token, :update, @rq_user
		check_privileges @access_token, :update, @rq_avatar

		@rq_avatar.set_current
		render_event :ok, @rq_user.build_response({User.RS_DATA[:AVATAR] => true})
	end

	def delete
		check_privileges @access_token, :update, @rq_user
		check_privileges @access_token, :destroy, @rq_avatar

		@rq_avatar.destroy
		render_event :ok
	end

	private

	def avatar_params
		params.permit(:data, :content_type, :crop_x, :crop_y, :crop_l)
	end

	def check_avatar
		id = params[:avatar_id]
		logger.info "check avatar ##{id}..."
		raise ApiExceptions::NotFound::Image.new(id) unless Image.where(id: id).present?
		@rq_avatar = Image.find(id)
		logger.info 'finded!'
	end

end
