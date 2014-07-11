class CompanyController < ApplicationController

	include CompanyHelper

	def get
		id = params[:id]
		render json: get_fake_company(id)
	end

end
