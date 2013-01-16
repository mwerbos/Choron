Choron::Application.routes.draw do
  get "bounty/show"

  resources :auctions

  resources :bounties

  resources :bids

  resources :chores

  resources :users, :user_sessions
  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  match 'admin' => 'user_sessions#make_admin', :as => :admin
  match 'user_sessions/confirm_admin' => 'user_sessions#confirm_admin'

  match '/chores/take/:id' => 'chores#take_chore'
  put   '/chores/complete/:id' => 'chores#complete'
  match '/chores/undo/:id' => 'chores#undo'
  match 'chores/destroy_repeating_chore/:id' => 'chores#destroy_repeating_chore'

  match '/auctions/new/for_chore/:chore_id' => 'auctions#new'
  match '/auctions/new_bid/:auction_id' => 'bids#new'

  match '/home' => 'home#my_chores'
  match '/home/chore_market' => 'home#chore_market'
  match '/home/chore_market/:view' => 'home#chore_market'
  match '/users/:user_id/give_chorons' => 'home#give_chorons_form'
  match 'home/give_chorons' => 'home#give_chorons'
  match 'home/new_chore_auction' => 'home#make_chore_auction_form'
  match 'home/make_chore_auction' => 'home#make_chore_auction'
  get   'home/preferences' => 'home#get_preferences_list'
  get   'home/preferences/:chore_id' => 'home#show_preference'
# put   'home/preferences/:chore_id' => 'home#edit_preference'
  
  root :to => 'user_sessions#new', :as => :login

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
