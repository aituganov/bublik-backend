include AppUtils

class Api::Company::Social::SocialController < Api::Company::CompaniesController

	def followers
		check_privileges @requester, :read, @company
		render_event :ok, @company.build_response({Company.RS_DATA[:FOLLOWERS] => true}, socialization_params.merge({requester: @requester}))
	end

	private

	def socialization_params
		params.permit(:limit, :offset)
	end
end