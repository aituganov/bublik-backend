class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

	def page_not_found
		render html: 'Requested resource not found', status: :not_found, layout: false
	end

  def test_method
	  puts 'OLD'
  end

end
