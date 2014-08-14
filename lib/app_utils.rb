require 'rack/mime'

module AppUtils
	def get_access_token(cookies)
		cookies[:ACCESS_TOKEN]
	end

	def get_user_by_access_token(cookies)
		access_token = get_access_token cookies
		logger.info "Find user by access token #{access_token}..."
		unless access_token.blank?
			raise ApiExceptions::User::Unauthorized.new(access_token) if !access_token.nil? && !User.where(access_token: access_token).present?
			res = User.where(access_token: access_token).take
			logger.info "User #{res.id} founded!"
		else
			logger.info 'User is anonymous!'
		end

		res
	end

	def check_privileges(requester, action, requested, render_er=true)
		requester ||= User.new # Anonymous user
		logger.info "Check privileges for #{requester.class} ##{requester.id} to #{action} #{requested.class} ##{requested.id}..."
		ability = Ability.new requester
		raise ApiExceptions::User::NotAllowed.new(action, requester.id) unless ability.can? action, requested
		logger.info 'accepted!'
	end

	def avatar_params_valid?(avatar)
		res = !(avatar[:data].nil? || avatar[:content_type].nil? || avatar[:crop_x].nil? || avatar[:crop_y].nil? || avatar[:crop_l].nil?)
		raise_exception ArgumentError, 'Invalid request data' unless res
	end

	def build_privileges(requester, requested_objects)
		requester ||= User.new # User is anonymous
		ability = Ability.new requester
		logger.info "Build privileges for #{requester.class} ##{requester.id}..."
		rs = ability.build_privileges Array(requested_objects)
		logger.info "Builded: #{rs.to_json}"
		rs
	end

	def build_socials(requester, requested_objects)
		requester ||= User.new # User is anonymous
		ability = Ability.new requester
		logger.info "Build social actions for #{requester.class} ##{requester.id}..."
		rs = ability.build_social_actions Array(requested_objects)
		logger.info "Builded: #{rs.to_json}"
		rs
	end

	def put_privileges_data(rs, object, requester)
		rs[:actions] = build_privileges requester, object
	end

	def put_social_data(rs, object, requester)
		rs[:social] = build_socials requester, object
	end

	def log_exception(ex)
		logger.error "#{ex.class}: #{ex.message}\n #{ex.backtrace.join("\n")}"
	end

	def from_cache(key)
		from_cache = Rails.cache.read(key)
		logger.info "Take #{key} from cache"
		if (from_cache.nil?)
			logger.info 'Not found'
		else
			logger.info "Taked: #{from_cache}"
		end
		from_cache
	end

	def to_cache(key, val)
		logger.info "Write #{key}: #{val.nil? ? 'null' : val.to_s} to cache"
		Rails.cache.write(key, val)
	end

	def raise_exception(type, object)
		raise type, object
	end
end