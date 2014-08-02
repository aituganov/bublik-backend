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

	def get_access_token(cookies)
		cookies[:ACCESS_TOKEN]
	end

	def get_user_by_access_token(access_token)
		User.where(access_token: access_token).take
	end

	def check_privileges(access_token, action, requested, render_er=true)
		requester = get_user_by_access_token(access_token) || User.new # invalid token or new user
		logger.info "Check privileges for #{requester.class} ##{requester.id} to #{action} #{requested.class} ##{requested.id}..."
		ability = Ability.new requester
		res = true

		unless ability.can? action, requested
			render_error :forbidden if render_er
			res = false
		end
		res
	end

	def build_privileges(access_token, requested_objects)
		requester = get_user_by_access_token(access_token) || User.new # invalid token or new user
		ability = Ability.new requester
		logger.info "Build privileges for #{requester.class} ##{requester.id}..."
		rs = ability.build_privileges Array(requested_objects)
		logger.info "Builded: #{rs.to_json}"
		rs
	end

end
