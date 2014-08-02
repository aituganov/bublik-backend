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

		can :rud, Company, :owner_id => user.id
		can :read, Company
	end

	def build_privileges(requested_objects)
		privileges = {'actions' => {}}

		requested_objects.each do |requested|
			actions = []
			get_actions.each do |action|
				actions.push action.to_s if can? action, requested
			end
			privileges['actions'][requested.class.name.downcase] = actions
		end

		privileges
	end

	private

	def get_actions
		[:create, :read, :update, :destroy]
	end
end
