#require 'exception'

class ApiExceptions < StandardError
	attr_reader :message

	class NotFound < ApiExceptions

		def initialize(object_id)
			object_id ||= nil
			ex_class_name = self.class.name.split('::').last
			@message = "#{ex_class_name} ##{object_id} isn't founded"
		end

		class User < NotFound
		end

		class Company < NotFound
		end

		class Image < NotFound
		end
	end

	class User < ApiExceptions
		class NotAuthorized < User
		end

		class NotAllowed < User
			def initialize(action, user_id)
				@message = "#{action} not allowed for User ##{user_id}"
			end
		end
	end
end