#require 'exception'

class ApiExceptions < StandardError
	attr_reader :message

	def initialize(message)
		@message = message
	end

	class NotFound < ApiExceptions

		def initialize(object_id)
			object_id ||= nil
			ex_class_name = self.class.name.split('::').last
			super "#{ex_class_name} ##{object_id} isn't founded"
		end

		class User < NotFound; end
		class Company < NotFound; end
		class Image < NotFound; end
	end

	class User < ApiExceptions
		class Unauthorized < User;
			def initialize(access_token)
				super "User with #{access_token} access token isn't authorized"
			end
		end

		class NotAllowed < User
			def initialize(action, user_id)
				super "#{action} not allowed for User ##{user_id}"
			end
		end
	end
end