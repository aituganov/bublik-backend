include ApplicationHelper

class Api::MenuController < Api::ApplicationController

	def get
		if @requester.nil?
			render_event :ok, {user: {anonymous: true}, menu_items: []}
		else
			render_event :ok, @requester.get_menu
		end
	end

end
