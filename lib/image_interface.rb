include ApplicationHelper

module ImageInterface
	def image_index
		check_privileges @requester, :read, image_owner
		rs = image_owner.build_response(rs_data, {requester: @requester})
		render_event :ok, rs
	end

	def image_create
		check_privileges @requester, :update, image_owner
		check_privileges @requester, :create, Image.new
		avatar_params_valid? image_params

		new_image = image_owner.images.build image_params
		new_image.save! && new_image.set_current
		render_event :ok, new_image.build_response(@requester)
	end

	def image_set_current
		check_privileges @requester, :update, image_owner
		check_privileges @requester, :update, @image

		@image.set_current
		render_event :ok, @image.build_response(@requester)
	end

	def image_delete
		check_privileges @requester, :update, image_owner
		check_privileges @requester, :destroy, @image

		@image.destroy!
		render_event :ok
	end

	def check_image
		id = image_id
		logger.info "check image ##{id}..."
		raise ApiExceptions::NotFound::Image.new(id) unless Image.where(id: id).present?
		@image = Image.find(id)
		logger.info 'finded!'
	end

	protected

	def image_id
		raise NotImplementedError.new 'method not implemented'
	end

	def rs_data
		raise NotImplementedError.new 'method not implemented'
	end

	def image_owner
		raise NotImplementedError.new 'method not implemented'
	end

	def image_params
		raise NotImplementedError.new 'method not implemented'
	end

end