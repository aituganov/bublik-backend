include ApplicationHelper
include UsersHelper
include ImageInterface

class Api::User::Avatars::AvatarsController < Api::User::UsersController
	before_filter :check_avatar, only: [:set_current, :delete]

	def index
		image_index
	end

	def create
		image_create
	end

	def set_current
		image_set_current
	end

	def delete
		image_delete
	end

	private

	def rs_data
		{User.RS_DATA[:AVATARS] => true}
	end

	def image_reference
		@rq_user.images
	end

	def image_owner
		@rq_user
	end

	def image_params
		params.permit(:data, :content_type, :crop_x, :crop_y, :crop_l)
	end

	def check_avatar
		id = params[:avatar_id]
		logger.info "check avatar ##{id}..."
		raise ApiExceptions::NotFound::Image.new(id) unless Image.where(id: id).present?
		@image = Image.find(id)
		logger.info 'finded!'
	end

end
