Rails.application.routes.draw do

  resources :tags

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
	scope :path => 'api' do
		get 'localization' => 'localization#get'
		get 'widget/:id' => 'widgets#get'

		get 'version' => 'versions#current_version'

		# Route menu
		scope :path => 'menu' do
			get '/' => 'menu#get'
		end

		# Route users
		scope :path => 'user' do
			# Create
			match 'new' => 'users#registration', via: [:put]
			# Login
			match 'login' => 'users#login', via: [:put]
			get 'login/check/:login' => 'users#check_login', constraints: { login: /.*/ }
			# Info
			get ':id' => 'users#index'
			get ':id/created_companies' => 'users#created_companies'
			# Updaters
			post ':id' => 'users#update'
			post ':id/avatar' => 'users#update_avatar'
			match ':id/interests' => 'users#interests_add', via: [:put]
			match ':id/interests' => 'users#interests_delete' , via: [:delete]
			# Delete
			match ':id' => 'users#delete' , via: [:delete]
		end

		# Route companies
		scope :path => 'company' do
			match 'new' => 'companies#registration', via: [:put]
			get ':id' => 'companies#index'
			post ':id' => 'companies#update'
			match ':id' => 'companies#delete' , via: [:delete]
			match ':id/tags' => 'companies#tags_add', via: [:put]
			match ':id/tags' => 'companies#tags_delete' , via: [:delete]
		end

		# Route tags
		scope :path => 'tag' do
			get ':name' => 'tags#find'
		end

	end

	get '*path', :to => 'application#page_not_found'
end
