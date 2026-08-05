Rails.application.routes.draw do
  get "skus/show"
  get "categories/index"
  get "categories/show"
  root "home#index"
  get "about", to: redirect("/factory")
  get "factory", to: "home#factory"
  get "customize", to: "home#customize"
  get "privacy", to: "home#privacy"
    get "products", to: "home#all_products", as: :products
  get "contact", to: "home#contact"
  get "faqs", to: "home#faqs"
  post "contact", to: "home#create_contact"

  namespace :admin do
    resources :partners
    root to: "dashboard#index"
    get "dashboard", to: "dashboard#index"
    resources :categories
    resources :skus do
      collection do
        get :export
        patch :update_positions
      end
      member do
        delete :delete_image
      end
    end
    resources :posts
    resources :faq_categories
    resources :faqs
    resources :contact_messages, only: [:index, :show, :destroy]
    resources :visit_records, only: [:index] do
      collection do
        delete :clean
      end
    end
    resources :login_logs, only: [:index] do
      collection do
        delete :clear
      end
    end
    resources :operation_logs, only: [:index, :show] do
      collection do
        delete :clear
      end
    end
    resource :site_config, only: [:edit, :update]
    resources :users, only: [:index, :edit, :update, :destroy] do
      member do
        patch :promote
      end
    end
    resource :profile, controller: 'profiles', only: [:show, :edit, :update]
    resources :orders, only: [:index, :show, :destroy, :update]
  end

  %w[apple huawei oppo vivo xiaomi custom].each do |kind|
    get kind, to: "channels#index", defaults: { kind: kind }, as: "#{kind}_channel"
  end

  resources :categories, only: [:index, :show]
  resources :skus, only: [:show]
  resources :posts, only: [:index, :show]
  resource :order, only: [:create] do
    post :add_item
    delete :remove_item
    patch :update_item
    get :cart_items
  end

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  
  # Handle common missing routes to reduce RoutingError noise
  get "/robots.txt", to: "home#robots"
  get "/sitemap.xml", to: "home#sitemap"
  get "/favicon.ico", to: ->(env) { [204, {}, [""]] }
  # get "/sitemap.xml", to: ->(env) { [404, {}, ["Not Found"]] }
  get "/.well-known/traffic-advice", to: ->(env) { [404, {}, ["Not Found"]] }
  
  # New routes to handle common bot/crawler requests
  get "/apple-touch-icon.png", to: ->(env) { [404, {}, [""]] }
  get "/apple-touch-icon-precomposed.png", to: ->(env) { [404, {}, [""]] }
  get "/apple-app-site-association", to: ->(env) { [404, {}, [""]] }
  get "/.well-known/apple-app-site-association", to: ->(env) { [404, {}, [""]] }
  get "/atom.xml", to: ->(env) { [404, {}, [""]] }
  get "/.git/config", to: ->(env) { [404, {}, [""]] }
  get "/xmlrpc.php", to: ->(env) { [404, {}, [""]] }
  match "/wp-includes/*path", to: ->(env) { [404, {}, [""]] }, via: :all
  match "/wp-json/*path", to: ->(env) { [404, {}, [""]] }, via: :all
  match "/blog/wp-includes/*path", to: ->(env) { [404, {}, [""]] }, via: :all
  match "/test/wp-includes/*path", to: ->(env) { [404, {}, [""]] }, via: :all
  match "/wp2/wp-includes/*path", to: ->(env) { [404, {}, [""]] }, via: :all
  
  # Handle legacy paths
  match "/product-page/*path", to: ->(env) { [404, {}, [""]] }, via: :all
  match "/category/*path", to: ->(env) { [404, {}, [""]] }, via: :all
  match "/_api/*path", to: ->(env) { [404, {}, [""]] }, via: :all
end
