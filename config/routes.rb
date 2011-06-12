Mojo::Application.routes.draw do
  
  resources :invitations, :only => [:new, :create]

  get "invitations/find"

  resources :password_resets

  # TODO: pretty up URL/namespace it into account
  get "places/search"

  # TODO: pretty up these urls (like subscribers)
  resources :user_sessions
  match 'login' => "user_sessions#new",      :as => :login
  match 'logout' => "user_sessions#destroy", :as => :logout

  # route bellow uses userhome_path(:action) as helper
  # match "/userhome(/:action)", :controller => :userhome, :as => "userhome"
  
  #resources :users, :path => "account", :only => :create
  scope '/account', :controller => :users, :as => "account" do
    put "/" => :update
    get "/:account_section" => :edit, :as => :edit
    
    get "/signup/:invitation_token" => :signup, :as => "signup"
    post "/signup/:invitation_token" => :create
    
    get "/" => :index
  end
  
  # pretty-up
  scope '/invitation', :controller => :invitations, :as => "invitation" do
    get "/enter" => :enter
    post "/enter" => :find
  end
  
  scope '/userhome', :controller => :userhome, :as => "userhome" do
    # match "(/index)" interferes with link_to_unless_current
    root :to => :index, :as => ""
    match "/dates"
  end

  # todo: refactor stepflow routes, at least namespace
  # stepflow is disabled: refactor for open-beta with state machine
  #scope '/stepflow', :controller => :stepflow, :as => "stepflow" do
    
    # action go, next, previous, cancel
    #get "/" => :go
    #post "/" => :next
    #post "/previous"
    #get "/cancel"
    
    # TODO: move to sortie controller?
    #get "/created"
    #get "/joined"
  #end
  
  # Twilio, TODO: use https and twilio-ruby verification
  match "/sms" => "sms#receive"

  # todo: namespace it
  match "/entries/:id/confirmation", :to => "entries#confirmation", :constraints => {:id => /\d+/}
  match "/entries/pass/:entry", :to => "entries#pass", :constraints => {:entry => /\d+/}
  match "/entries/invite/:entry", :to => "entries#invite", :constraints => {:entry => /\d+/}
  match "/entries/:id", :to => "entries#waitlist", :constraints => {:id => /\d+/}
  
  get 'sorties/new'
  post 'sorties' => "sorties#create"
  get 'sorties/join'
  get 'sorties/:id' => "sorties#confirmation"
  
  # todo: password protect
  namespace "admin" do
    resources :entries, :users, :sorties
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
