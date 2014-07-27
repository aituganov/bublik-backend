include ApplicationHelper

class TagsController < ApplicationController
	before_action :check_user

	def find
		tags = Tag.arel_table
		finded = Tag.where(tags[:name].matches("%#{tag_params[:name]}%")).limit(tag_params[:limit] || AppSettings.limit_default)
		render_event :ok, {tags: finded.map{|t| {name: t.name, id: t.id}}}
	end

	def new
		tag = Tag.new(tag_params)
		if !Tag.where(tag_params).take.nil?
			render_error :conflict, 'Tag already registered'
		elsif tag.save
			render_event :created, {tag: {name: tag.name, id: tag.id}}
		else
			render_error :bad_request, tag.errors
		end
	end

	private

	def check_user
		user = get_user_by_access_token(cookies)
		render_error :not_found, {error: 'User not found'} if user.nil?
	end

	def tag_params
		params.permit(:name, :limit)
	end

end
