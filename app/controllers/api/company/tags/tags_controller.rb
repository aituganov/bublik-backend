class Api::Company::Tags::TagsController < Api::Company::CompaniesController
	before_filter :check_company, except: [:index, :registration]

	def add
		check_privileges access_token, :update, company

		company.tags_add tag_params
		render_event :created
	end

	def delete
		check_privileges access_token, :update, company

		company.tags_delete tag_params
		render_event :ok
	end

	private

	def tag_params
		params.require(:tags)
	end

end
