class Ability
	include CanCan::Ability

	def initialize(user)
		user ||= User.new # guest user (not logged in)
		#   if user.admin?
		#     can :manage, :all
		#   else
		#     can :read, :all
		#   end
		#
		# The first argument to `can` is the action you are giving the user
		# permission to do.
		# If you pass :manage it will apply to every action. Other common actions
		# here are :read, :create, :update and :destroy.
		#
		# The second argument is the resource the user can perform the action on.
		# If you pass :all it will apply to every resource. Otherwise pass a Ruby
		# class of the resource.
		#
		# The third argument is an optional hash of conditions to further filter the
		# objects.
		# For example, here the user can only update published articles.
		#
		#   can :update, Article, :published => true
		#
		# See the wiki for details:
		# https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
		alias_action :read, :update, :destroy, :to => :rud
		alias_action :create, :read, :update, :destroy, :to => :crud

		can :rud, User, :id => user.id
		can :read, User

		unless user.id.nil?
			can :create, [Company, Image], :id => nil
		end

		can :follow, [User, Company] do |object|
			res = true
			if object.class == User
				res = object.id != user.id # User can't follow himself
			end
			res && !user.id.nil? && !user.follows?(object)
		end

		can :unfollow, [User, Company] do |object|
			!user.id.nil? && user.follows?(object)
		end

		can :read, [Company, Image]
		can :rud, Company, :owner_id => user.id
		can :rud, Image do |image|
			if image.imageable_type == user.class.name
				res = image.imageable == user
			elsif image.imageable_type == Company.name
				res = image.imageable.owner == user
			end
			res
		end
	end

	def build_privileges(requested_objects)
		privileges = {}

		requested_objects.each do |requested|
			crud_actions.each do |action|
				privileges[action] = can? action, requested
			end
		end
		privileges
	end

	def build_social_actions(requested_objects)
		privileges = {}

		requested_objects.each do |requested|
			social_actions.each do |action|
				privileges[action] = can? action, requested
			end
		end
		privileges
	end

	private

	def crud_actions
		[:create, :read, :update, :destroy]
	end

	def social_actions
		[:follow, :unfollow]
	end
end
