module ApplicationHelper

	def render_event(code, data=nil)
		rs = {status: code}
		if !data.nil?
			rs[:data] = data
		end
		logger.info "Response: #{rs.to_json}"
		render json: rs, status: code
	end

	def render_error(code, errors=nil)
		rs = {status: code}
		if !errors.nil?
			rs[:errors] = errors
		end
		logger.error "Response: #{rs.to_json}"
		render json: rs, status: code
	end

	def get_access_token(cookies)
		cookies[:ACCESS_TOKEN]
	end

	def get_user_by_access_token(cookies)
		User.where(access_token: get_access_token(cookies)).take
	end

end
