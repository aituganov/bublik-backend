class Api::User::Companies::CreatedCompaniesController < Api::User::UsersController
	before_filter :check_user

	def index
		render_event :ok, rq_user.build_response({User.RS_DATA[:CREATED_COMPANIES] => true}, {access_token: access_token, offset: user_params[:company_offset], limit: user_params[:company_limit]})
	end

end