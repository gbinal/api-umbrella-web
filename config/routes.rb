ApiUmbrella::Application.routes.draw do

  get "/doc/api-key" => "pages#api_key", :as => :doc_api_key
  get "/doc/errors" => "pages#errors"
  get "/doc/rate-limits" => "pages#rate_limits", :as => :doc_rate_limits

  get "/doc" => "api_doc_collections#index"
  get "/doc/api/:path" => "api_doc_services#show", :as => :api_doc_service, :constraints => { :path => /.*/ }
  get "/doc/:slug" => "api_doc_collections#show", :as => :api_doc_collection

  get "/community" => "pages#community"

  resource :account, :only => [:create] do
    get "terms", :on => :collection
  end

  get "/signup" => "accounts#new"

  get "/contact" => "contacts#new"
  post "/contact" => "contacts#create"

  root :to => "pages#home"

  # Mount the API at both /api/ and /api-umbrella/ for backwards compatibility.
  %w(api api-umbrella).each do |path|
    namespace(:api, :path => path) do
      resources :api_users, :path => "api-users", :only => [:show, :create] do
        member do
          get "validate"
        end
      end

      resources :health_checks, :path => "health-checks", :only => [] do
        collection do
          get :ip
          get :logging
        end
      end

      resource :hooks, :only => [] do
        post "publish_static_site"
      end

      namespace :v1 do
        resources :admins
        resources :apis
        resources :users
      end
    end
  end

  devise_for :admins, :controllers => { :omniauth_callbacks => "admin/admins/omniauth_callbacks" }

  devise_scope :admin do
    get "/admin/login" => "admin/sessions#new", :as => :new_admin_session
    get "/admin/logout" => "admin/sessions#destroy", :as => :destroy_admin_session
  end

  match "/admin" => "admin/base#empty"

  namespace :admin do
    resources :admins, :only => [:index]
    resources :api_users, :only => [:index]
    resources :apis, :only => [:index] do
      member do
        put "move_to"
      end
    end

    resources :stats, :only => [:index] do
      collection do
        get "search"
        get "logs"
        get "users"
        get "map"
      end
    end

    namespace :config do
      get "publish", :action => "show"
      post "publish", :action => "create"

      get "import_export"
      get "export"
      post "import_preview"
      post "import"
    end

    resources :api_doc_services do
      get "page/:page", :action => :index, :on => :collection
    end

    resources :api_doc_collections do
      get "page/:page", :action => :index, :on => :collection
    end

    resources :api_users do
      get "page/:page", :action => :index, :on => :collection
    end
  end
end
