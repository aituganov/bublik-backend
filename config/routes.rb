Rails.application.routes.draw do

	# The priority is based upon order of creation: first created -> highest priority.
	# See how all your routes lay out with "rake routes".

	# You can have the root of your site routed with "root"
	# root 'welcome#index'

	# Example of regular route:
	#   get 'products/:id' => 'catalog#view'

	# Example of named route that can be invoked with purchase_url(id: product.id)
	#   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

	# Example resource route (maps HTTP verbs to controller actions automatically):
	#   resources :products

	# Example resource route with options:
	#   resources :products do
	#     member do
	#       get 'short'
	#       post 'toggle'
	#     end
	#
	#     collection do
	#       get 'sold'
	#     end
	#   end

	# Example resource route with sub-resources:
	#   resources :products do
	#     resources :comments, :sales
	#     resource :seller
	#   end

	# Example resource route with more complex sub-resources:
	#   resources :products do
	#     resources :comments
	#     resources :sales do
	#       get 'recent', on: :collection
	#     end
	#   end

	# Example resource route with concerns:
	#   concern :toggleable do
	#     post 'toggle'
	#   end
	#   resources :posts, concerns: :toggleable
	#   resources :photos, concerns: :toggleable

	# Example resource route within a namespace:
	#   namespace :admin do
	#     # Directs /admin/products/* to Admin::ProductsController
	#     # (app/controllers/admin/products_controller.rb)
	#     resources :products
	#   end

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

		end

		# Route companies
		namespace :company do
			match 'new' => 'companies#registration', via: [:put]
			get ':id' => 'companies#index'
			post ':id' => 'companies#update'
			match ':id' => 'companies#delete', via: [:delete]
			# Tags
			match ':id/tags' => 'tags/tags#add', via: [:put]
			match ':id/tags' => 'tags/tags#delete', via: [:delete]
		end

		# Route search
		namespace :search do
			# Tags
			scope :path => 'tag' do
				get ':name' => 'tags#find'
			end
		end
	end


	get '*path', :to => 'application#page_not_found'
end
