class Api::User::Interests::InterestsController < Api::User::UsersController
	#before_filter :check_user

	def add
		check_privileges @access_token, :update, @rq_user

		@rq_user.interests_add interests
		render_event :created
	end

	def delete
		check_privileges @access_token, :update, @rq_user

		@rq_user.interests_delete interests
		render_event :ok
	end

	private

	def interests
		params.require(:interests)
	end

end
