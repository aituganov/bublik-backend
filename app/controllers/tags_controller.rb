include ApplicationHelper

class TagsController < ApplicationController
	before_action :check_user

	def find
		tags = Tag.arel_table
		finded = Tag.where(tags[:name].matches("%#{tag_params[:name]}%")).limit(tag_params[:limit] || AppSettings.limit_default)
		render_event :ok, {tags: finded.map{|t| {name: t.name, id: t.id}}}
	end

	private

	def check_user
		user = get_user_by_access_token(get_access_token(cookies))
		render_error :not_found, {error: 'User not found'} if user.nil?
	end

	def tag_params
		params.permit(:name, :limit)
	end

end
