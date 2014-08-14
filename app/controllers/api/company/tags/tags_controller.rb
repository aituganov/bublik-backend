class Api::Company::Tags::TagsController < Api::Company::CompaniesController

	def add
		check_privileges @requester, :update, @company

		@company.tags_add tag_params
		render_event :created
	end

	def delete
		check_privileges @requester, :update, @company

		@company.tags_delete tag_params
		render_event :ok
	end

	private

	def tag_params
		params.require(:tags)
	end

end
