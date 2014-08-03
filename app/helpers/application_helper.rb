module ApplicationHelper

	def render_event(code, data=nil)
		if !data.nil?
			rs = {data: data}
		else
			rs = {status: code}
		end
		logger.info "Response: #{rs ? rs.to_json : code}"
		render json: rs, status: code
	end

	def render_error(code, errors=nil)
		if !errors.nil?
			rs = {errors: errors}
		else
			rs = {status: code}
		end
		logger.error "Response: #{rs.to_json}"
		render json: rs, status: code
	end

end
