class Api::User::Companies::CreatedCompaniesController < Api::User::UsersController

	def index
		render_event :ok, @rq_user.build_response({User.RS_DATA[:CREATED_COMPANIES] => true}, {requester: @requester, offset: user_params[:offset], limit: user_params[:limit]})
	end

end