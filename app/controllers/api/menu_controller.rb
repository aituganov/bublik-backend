include ApplicationHelper

class Api::MenuController < Api::ApplicationController

	def get
		if @requester.nil?
			render_event :ok, {anonymous: true, menu: []}
		else
			render_event :ok, @requester.get_menu
		end
	end

end
