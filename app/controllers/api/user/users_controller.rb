class Api::User::UsersController < Api::ApplicationController
	before_filter :check_user, except: [:registration, :login, :check_login]

	def index
		render_event :ok, @rq_user.build_response({User.RS_DATA[:FULL] => true}, {requester: @requester, limit: user_params[:limit]})
	end

	def registration
		user = User.create!(user_params)
		render_event :created, {id: user.id, access_token: user.access_token}
	end

	def login
		user = User.where(user_params).take
		if user.nil?
			render_error :unauthorized
		else
			render_event :ok, {id: user.id, access_token: user.access_token}
		end
	end

	def check_login
		user = User.where(login: user_params[:login]).take
		if user.nil?
			render_event :ok
		else
			render_event :created
		end
	end

	def update
		check_privileges @requester, :update, @rq_user

		@rq_user.update!(user_params)
		render_event :ok
	end

	def delete
		check_privileges @requester, :destroy, @rq_user

		@rq_user.destroy!
		render_event :ok
	end

	private

	def check_user
		id = params[:id]
		logger.info "check user ##{id}..."
		if !@requester.nil? && @requester.id == id
			logger.info 'Request user is requester!'
			@rq_user = @requester
		else
			raise ApiExceptions::NotFound::User.new(id) unless User.where(id: id).present?
			@rq_user = User.find(params[:id])
		end
		logger.info 'finded!'
	end

	def user_params
		params.permit(:login, :password, :last_name, :first_name, :limit, :offset)
	end

end
