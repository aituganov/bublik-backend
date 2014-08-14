include ApplicationHelper
include AppUtils

class Api::ApplicationController < ApplicationController
	skip_before_filter :verify_authenticity_token
	before_action :set_requester
	rescue_from ApiExceptions::NotFound, with: :object_not_found
	rescue_from ApiExceptions::User::Unauthorized, with: :user_unauthorized
	rescue_from ApiExceptions::User::NotAllowed, with: :not_allowed
	rescue_from ActionController::ParameterMissing, ActiveRecord::RecordInvalid, ArgumentError, with: :bad_rq

	private

	def set_requester
		@requester = get_user_by_access_token cookies
	end

	# Rescuers
	def not_allowed(ex)
		render_error :forbidden, ex.message
	end

	def bad_rq(ex)
		render_error :bad_request, ex.message
	end

	def object_not_found(ex)
		render_error :not_found, ex.message
	end

	def user_unauthorized(ex)
		render_error :unauthorized, ex.message
	end
end