include CompaniesHelper

class Api::Company::CompaniesController < Api::ApplicationController
	before_filter :check_company, except: [:registration]

	def index
		render_event :ok, @company.build_response({Company.RS_DATA[:FULL] => true}, {access_token: @access_token})
	end

	def registration
		check_privileges @access_token, :create, Company.new

		company = Company.create! company_params.merge({owner: get_user_by_access_token(@access_token)})
		render_event :created, {id: company.id}
	end

	def update
		check_privileges @access_token, :update, @company

		@company.update!(company_params)
		render_event :ok
	end

	def delete
		check_privileges @access_token, :destroy, @company

		@company.destroy!
		render_event :ok
	end

	private

	def company_params
		params.permit(:title, :slogan, :description)
	end

	def check_company
		id = params[:id]
		logger.info "Check company ##{id}..."
		raise ApiExceptions::NotFound::Company.new(id) unless Company.where(id: id).present?
		@company = Company.find(params[:id])
		logger.info 'finded!'
	end

end
