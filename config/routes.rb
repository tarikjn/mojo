Mojo::Application.routes.draw do
  
  resources :user_sessions
  match 'login' => "user_sessions#new",      :as => :login
  match 'logout' => "user_sessions#destroy", :as => :logout

  match "/userhome" => "userhome#index"

  # todo: refactor stepflow routes, at least namespace
  match "stepflow" => "stepflow#discover"
  post "stepflow/discover" => "stepflow#discover_submit"
  get "stepflow/discover"
  get "stepflow/join"
  post "stepflow/join" => "stepflow#join_submit"
  post "stepflow/create" => "stepflow#create_submit"
  get "stepflow/create"
  post "stepflow/profile" => "stepflow#profile_submit"
  get "stepflow/profile"
  post "stepflow/review" => "stepflow#review_submit"
  get "stepflow/review"
  
  get "stepflow/finish"
  
  get "stepflow/map"
  post "stepflow/map"
  
  get "stepflow/created"
  
  match "/sms" => "sms#receive"

  # todo: namespace it
  match "/entries/:id/confirmation", :to => "waitlist_entries#confirmation", :constraints => {:id => /\d+/}
  match "/entries/pass/:entry", :to => "waitlist_entries#pass", :constraints => {:entry => /\d+/}
  match "/entries/invite/:entry", :to => "waitlist_entries#invite", :constraints => {:entry => /\d+/}
  match "/entries/:id", :to => "waitlist_entries#waitlist", :constraints => {:id => /\d+/}
  resources :waitlist_entries

  resources :users

  resources :activities

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
  root :to => "homepage#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
