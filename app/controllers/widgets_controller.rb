class WidgetsController < ApplicationController
	include WidgetsHelper

	before_filter :validate_params

	def get
		render json: get_fake_widget(@id, @level, @offset.to_i, @limit.to_i)
	end

	private
	def validate_params
		@id = params[:id]
		@offset = params[:offset] || AppSettings.offset_default
		@level = params[:level] || AppSettings.widgets.level_default
		@limit = params[:limit] || AppSettings.widgets.limit_default
		logger.info "Getting widget with param: wdidget_id: #{@id}, level: #{@level}, offset: #{@offset}, limit: #{@limit}"
	end

end
