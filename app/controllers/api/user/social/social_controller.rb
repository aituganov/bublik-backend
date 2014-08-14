include AppUtils

class Api::User::Social::SocialController < Api::User::UsersController
	before_action :get_followed
	before_action :check_update, except: [:company_followed, :user_followed, :user_followers]
	before_action :check_read, only: [:company_followed, :user_followed, :user_followers]

	def company_follow
		check_privileges @requester, :follow, @followed
		@rq_user.follow! @followed
		render_event :ok
	end

	def company_unfollow
		check_privileges @requester, :unfollow, @followed
		@rq_user.unfollow! @followed
		render_event :ok
	end

	def company_followed
		render_event :ok, @rq_user.build_response({User.RS_DATA[:FOLLOWED_COMPANIES] => true}, socialization_params)
	end

	def user_follow
		check_privileges @requester, :follow, @followed
		@rq_user.follow! @followed
		render_event :ok
	end

	def user_unfollow
		check_privileges @requester, :unfollow, @followed
		@rq_user.unfollow! @followed
		render_event :ok
	end

	def user_followed
		render_event :ok, @rq_user.build_response({User.RS_DATA[:FOLLOWED_USERS] => true}, socialization_params)
	end

	def user_followers
		render_event :ok, @rq_user.build_response({User.RS_DATA[:FOLLOWERS] => true}, socialization_params)
	end

	private

	def socialization_params
		params.permit(:limit, :offset)
	end

	def get_followed
		if params[:company_id].present?
			id = params[:company_id]
			logger.info "Check company ##{id} for following..."
			raise ApiExceptions::NotFound::Company.new(id) unless Company.where(id: id).present?
			@followed = Company.find(id)
		elsif params[:user_id].present?
			id = params[:user_id]
			logger.info "Check company ##{id} for following..."
			raise ApiExceptions::NotFound::User.new(id) unless User.where(id: id).present?
			@followed = User.find(id)
		end

		logger.info 'finded!'
	end

	def check_read
		check_privileges @requester, :read, @rq_user
	end

	def check_update
		check_privileges @requester, :update, @rq_user
	end
end