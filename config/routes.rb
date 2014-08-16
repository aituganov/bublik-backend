Rails.application.routes.draw do
	namespace :api do
		get 'localization' => 'localization#get'
		get 'widget/:id' => 'widgets#get'

		get 'version' => 'versions#current_version'

		# Route menu
		scope :path => 'menu' do
			get '/' => 'menu#get'
		end

		# Route users
		namespace :user do
			# Create
			match 'new' => 'users#registration', via: [:put]
			# Login
			match 'login' => 'users#login', via: [:put]
			get 'login/check/:login' => 'users#check_login', constraints: {login: /.*/}
			# User
			get ':id' => 'users#index'
			post ':id' => 'users#update'
			match ':id' => 'users#delete', via: [:delete]
			# Created companies
			get ':id/created_companies' => 'companies/created_companies#index'
			# Avatars
			get ':id/avatars' => 'avatars/avatars#index'
			post ':id/avatar' => 'avatars/avatars#create'
			post ':id/avatar/current/:avatar_id' => 'avatars/avatars#set_current'
			match ':id/avatar/:avatar_id' => 'avatars/avatars#delete', via: [:delete]
			# Interests
			match ':id/interests' => 'interests/interests#add', via: [:put]
			match ':id/interests' => 'interests/interests#delete', via: [:delete]
			# Social
			post ':id/social/user/follow/:user_id' => 'social/social#user_follow'
			post ':id/social/user/unfollow/:user_id' => 'social/social#user_unfollow'
			get ':id/social/user/followed' => 'social/social#user_followed'
			get ':id/social/user/followers' => 'social/social#user_followers'

			post ':id/social/company/follow/:company_id' => 'social/social#company_follow'
			post ':id/social/company/unfollow/:company_id' => 'social/social#company_unfollow'
			get ':id/social/company/followed' => 'social/social#company_followed'
		end

		# Route companies
		namespace :company do
			match 'new' => 'companies#registration', via: [:put]
			get ':id' => 'companies#index'
			post ':id' => 'companies#update'
			match ':id' => 'companies#delete', via: [:delete]
			# Avatars
			get ':id/logotypes' => 'logotypes/logotypes#index'
			post ':id/logotype' => 'logotypes/logotypes#create'
			post ':id/logotype/current/:logo_id' => 'logotypes/logotypes#set_current'
			match ':id/logotype/:logo_id' => 'logotypes/logotypes#delete', via: [:delete]
			# Tags
			match ':id/tags' => 'tags/tags#add', via: [:put]
			match ':id/tags' => 'tags/tags#delete', via: [:delete]
			# Social
			get ':id/social/followers' => 'social/social#followers'
		end
		# Route search
		namespace :search do
			# Tags
			scope :path => 'tag' do
				post ':name' => 'tags#find'
			end
		end
		match '*path', :to => 'application#page_not_found', via: [:get, :post, :put, :delete]
	end

	match '*path', :to => 'application#page_not_found', via: [:get, :post, :put, :delete]
end
