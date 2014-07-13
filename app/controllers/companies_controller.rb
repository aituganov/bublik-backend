class CompaniesController < ApplicationController

	include CompaniesHelper

	def get
		id = params[:id]
		render json: get_fake_company(id)
	end

end
