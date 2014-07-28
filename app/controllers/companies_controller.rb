include CompaniesHelper
include ApplicationHelper

class CompaniesController < ApplicationController
	before_filter :get_user, except: [:get]
	before_filter :check_privileges, except: [:get, :registration]

	def get
		id = company_params[:id]
		begin
			company = Company.get_data(id) || get_fake_company(id)
		end
		render_event :ok, company
	end

	def registration
		company = Company.new company_params.merge({owner: @user})
		if company.save(company_params)
			render_event :created, {id: company.id}
		else
			render_error :bad_request, company.errors
		end
	end

	def update
		tags_errors = nil
		if !params[:tags].nil?
			tags_errors = @company.set_tags company_tags
		end
		if tags_errors && tags_errors.count > 0
			render_error :bad_request, tags_errors
		elsif @company.update(company_params)
			render_event :ok
		else
			render_error :bad_request, @company.errors
		end
	end

	def delete
		if @company.mark_as_deleted
			render_event :ok
		else
			render_error :bad_request, 'Company already deleted'
		end
	end

	private

	def company_params
		params.permit(:id, :title, :slogan, :description)
	end

	def company_tags
		params.require(:tags)
	end

	def get_user
		@user = get_user_by_access_token cookies
		render_error :not_found, 'User not found' if @user.nil?
	end

	def check_privileges
		company_id = company_params[:id]
		begin
			@company = Company.find(company_id)
			render_error :not_acceptable, 'Action isn\'t acceptable for this user' unless @company.owner.id == @user.id
		rescue ActiveRecord::RecordNotFound => e
			render_error :not_found, "Company #{company_id} not found"
		end
	end

end
