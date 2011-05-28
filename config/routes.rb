Mojo::Application.routes.draw do
  
  get "places/search"

  resources :user_sessions
  match 'login' => "user_sessions#new",      :as => :login
  match 'logout' => "user_sessions#destroy", :as => :logout

  # route bellow uses userhome_path(:action) as helper
  # match "/userhome(/:action)", :controller => :userhome, :as => "userhome"
  scope '/userhome', :controller => :userhome, :as => "userhome" do
    # match "(/index)" interferes with link_to_unless_current
    root :to => :index, :as => ""
    match "/dates"
    get "/settings"
    # replace with put
    post "/settings" => :update_settings
  end

  # todo: refactor stepflow routes, at least namespace
  scope '/stepflow', :controller => :stepflow, :as => "stepflow" do
    
    # action go, next, previous, cancel
    get "/" => :go
    post "/" => :next
    post "/previous"
    get "/cancel"
    
    # TODO: move to activity controller?
    get "/created"
    get "/joined"
  end
  
  # Twilio, TODO: use https and twilio-ruby verification
  match "/sms" => "sms#receive"

  # todo: namespace it
  match "/entries/:id/confirmation", :to => "waitlist_entries#confirmation", :constraints => {:id => /\d+/}
  match "/entries/pass/:entry", :to => "waitlist_entries#pass", :constraints => {:entry => /\d+/}
  match "/entries/invite/:entry", :to => "waitlist_entries#invite", :constraints => {:entry => /\d+/}
  match "/entries/:id", :to => "waitlist_entries#waitlist", :constraints => {:id => /\d+/}
  
  get 'activities/new'
  post 'activities' => "activities#create"
  get 'activities/join'
  get 'activities/:id' => "activities#confirmation"
  
  # todo: password protect
  namespace "admin" do
    resources :waitlist_entries, :users, :activities
  end

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
