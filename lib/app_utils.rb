require 'rack/mime'

module AppUtils
	class CarrierStringIO < StringIO
		attr_accessor :original_filename
		attr_accessor :content_type
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
			logger.warn 'forbidden!'
			render_error :forbidden if render_er
			res = false
		end
		logger.info 'accepted!'
		res
	end

	def avatar_params_valid?(avatar)
		res = !(avatar[:data].nil? || avatar[:content_type].nil? || avatar[:crop_x].nil? || avatar[:crop_y].nil? || avatar[:crop_l].nil?)
		render_error :bad_request unless res
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

	def put_privileges_data(rs, object, access_token)
		rs[:actions] = build_privileges access_token, object
	end

	def create_tmp_image(data_base_64, content_type)
		logger.info "Create image with content_type #{content_type}"
		prepared_data = !data_base_64.index('base64,').nil? ?
							data_base_64[(data_base_64.index('base64,') + 7)..-1] : data_base_64# cut content_type
		extension = Rack::Mime::MIME_TYPES.invert[content_type]  #=> ".jpg"
		logger.info "File extension #{extension}"
		@tmpfile = Tempfile.new([Time.now.to_time.to_i, extension], Rails.root.join('tmp'), encoding: 'BINARY')
		@tmpfile.write(Base64.decode64(prepared_data))
		file = CarrierWave::SanitizedFile.new(@tmpfile)
		file.content_type = content_type

		file
	end

	def clear_tmp_file
		return if @tmpfile.nil?

		@tmpfile.close!
		@tmpfile.unlink
	end

	def log_exception(ex)
		logger.error "#{ex.class}: #{ex.message}\n #{ex.backtrace.join("\n")}"
	end
end