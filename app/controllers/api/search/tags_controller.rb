include ApplicationHelper

class Api::Search::TagsController < Api::ApplicationController

	def find
		tags = Tag.arel_table
		finded = Tag.where.not(name: tag_params[:exclude]).where(tags[:name].matches("%#{tag_params[:name]}%")).limit(tag_params[:limit] || AppSettings.limit_default)
		render_event :ok, {tags: finded.map{|t| {name: t.name, id: t.id}}}
	end

	private

	def tag_params
		params.permit(:name, :limit, :offset, exclude: [])
	end

end
