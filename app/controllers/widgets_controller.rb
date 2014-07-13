class WidgetsController < ApplicationController
	include WidgetsHelper

	before_filter :validate_params

	def get
		logger.info "Getting widget with param: wdidget_id: #{@id}, level: #{@level}, offset: #{@offset}, limit: #{@limit}"

		render json: get_fake_widget(@id, @level, @offset.to_i, @limit.to_i)
	end

	private
	def validate_params
		@id = params[:id]
		@level = params[:level]
		@offset = params[:offset]
		@limit = params[:limit] || AppSettings.widgets.def_limit
		head :bad_request if (@level.nil? || @limit.nil? || @offset.nil?)
	end

end
