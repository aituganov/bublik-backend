include ImageInterface

class Api::Company::Logotypes::LogotypesController < Api::Company::CompaniesController
	before_filter :check_image, only: [:set_current, :delete]

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

	def image_id
		params[:logo_id]
	end

	def rs_data
		{Company.RS_DATA[:LOGOTYPES] => true}
	end

	def image_owner
		@company
	end

	def image_params
		params.permit(:image_data, :content_type, :crop_x, :crop_y, :crop_l)
	end

end
