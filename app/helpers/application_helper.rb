module ApplicationHelper

	def render_event(code, data=nil)
		rs = {status: code}
		if !data.nil?
			rs[:data] = data
		end
		render json: rs, status: code
	end

	def render_error(code, errors=nil)
		rs = {status: code}
		if !errors.nil?
			rs[:errors] = errors
		end
		render json: rs, status: code
	end

end
