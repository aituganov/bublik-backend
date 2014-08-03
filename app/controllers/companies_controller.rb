include ApplicationHelper
include AppUtils
include CompaniesHelper

class CompaniesController < ApplicationController
	before_filter :check_updated, except: [:get, :registration]

	def get
		id = company_params[:id]
		begin
			company = Company.get_data(id) || get_fake_company(id)
		end
		render_event :ok, company
	end

	def registration
		return unless check_privileges access_token, :create, Company.new

		company = Company.new company_params.merge({owner: get_user_by_access_token(access_token)})
		if company.save(company_params)
			render_event :created, {id: company.id}
		else
			render_error :bad_request, company.errors
		end
	end

	def update
		return unless check_privileges access_token, :update, company

		if company.update(company_params)
			render_event :ok
		else
			render_error :bad_request, company.errors
		end
	end

	def delete
		return unless check_privileges access_token, :destroy, company

		company.destroy
		render_event :ok
	end

	def tags_add
		return unless check_privileges access_token, :update, company
		begin
			company.tags_add tags
			render_event :created
		rescue ActionController::ParameterMissing => e
			render_error :bad_request
		end
	end

	def tags_delete
		return unless check_privileges access_token, :update, company
		begin
			company.tags_delete tags
			render_event :ok
		rescue ActionController::ParameterMissing => e
			render_error :bad_request
		end
	end

	private

	def company_params
		params.permit(:id, :title, :slogan, :description)
	end

	def tags
		params.require(:tags)
	end

	def check_updated
		unless Company.where(id: company_params[:id]).present?
			render_error :not_found, "Company ##{company_params[:id]} isn't founded"
		end
	end

	def company
		Company.find(company_params[:id])
	end

	def access_token
		get_access_token cookies
	end

end
