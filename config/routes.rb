require 'year_constraint'
require 'api_constraints'

Rails.application.routes.draw do
  default_url_options protocol: '//' # HTTP o HTTPS
  default_url_options host: Rails.application.secrets.rails_host

  namespace :api, defaults: {format: :json}, except: [:new, :edit] do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do

      resources :documentos, only: [:show, :create]

      resources :nota_entradas, only: [:index] do
        put :anular, on: :member
      end

      resources :solicitudes, only: [:index] do
        put :anular, on: :member
      end

      resources :users, only: [:obt_historico_actas] do
        get :obt_historico_actas, on: :member
        get :obt_activos, on: :member
      end

      resources :reportes, only: [:activos] do
        get :activos, on: :collection
      end

      resources :seguros, only: [:create, :update]

      resources :proveedores, only: [:index]

      resources :activos, only: [:index] do
        get :sin_seguro_vigente, on: :member
      end

      resources :requests, only: [:show] do
        post :validar_cantidades, on: :member
      end
    end
  end

  resources :gestiones, except: [:destroy] do
    put 'cerrar', on: :member
  end
  resources :ufvs, except: [:show, :destroy]
  resources :ubicaciones, except: [:show, :destroy]
  resources :ingresos do
    get :obt_cod_ingreso, on: :collection
  end

  resources :reportes do
    get 'kardex', on: :collection
    get 'activos', on: :collection
    get 'depreciacion', on: :collection
    get 'resumen', on: :collection
    get 'cuenta_contable', on: :collection
  end

  resources :entry_subarticles, only: [:edit, :update]

  resources :almacenes, only: [:index]

  resources :note_entries, except: [:destroy] do
    get :get_suppliers, on: :collection
    get :obt_cod_ingreso, on: :collection
  end

  # proveedores
  resources :suppliers

  resources :kardex_prices

  resources :kardexes

  resources :seguros do
    get :asegurar, on: :member
    get :incorporaciones, on: :member
    get :activos, on: :member
    get :resumen, on: :member
  end

  resources :derecognised, only: :index

  resources :requests, except: [:edit, :destroy] do
    get :search_subarticles, on: :collection
    get :obtiene_nro_solicitud, on: :collection
  end

  resources :materials, except: [:destroy] do
    post :change_status, on: :member
    get :reports, on: :collection
  end

  resources :articles, except: [:destroy] do
    post :change_status, on: :member
  end

  constraints YearConstraint do
    get '/subarticles/close/:year' => 'subarticles#close', as: 'close_subarticles'
    post '/subarticles/close/:year' => 'subarticles#close_subarticles'
  end

  resources :subarticles, except: [:destroy] do
    resources :kardexes
    member do
      post :change_status
      get :kardex
    end
    collection do
      get :articles
      get :get_subarticles
      get :recode
      get :autocomplete
      get :subarticles_array
      post :first_entry
    end
  end

  resources :barcodes, only: [:index] do
    collection do
      get :obt_cod_barra
      post :pdf
    end
  end

  resources :proceedings, only: [:index, :show, :create, :update]

  resources :declines, only: [:index]

  resources :versions, only: [:index] do
    post :export, on: :collection
  end

  resources :assets, except: [:destroy] do
    member do
      post :change_status
      get :historical
    end
    collection do
      get :autocomplete
      get :admin_assets
      get :search
      get :assignation
      get :devolution
      get :users
      get :departments
      get :recode
    end
  end

  resources :auxiliaries, except: [:destroy] do
    post :change_status, on: :member
  end

  resources :accounts, only: [:index, :show]

  resources :departments, except: [:destroy] do
    post :change_status, on: :member
    get :download, on: :member
  end

  resources :buildings, except: [:destroy] do
    post :change_status, on: :member
  end

  resources :entities

  resources :users, except: [:destroy] do
    post :change_status, on: :member
    get :welcome, on: :collection
    get :download, on: :member
    get :autocomplete, on: :collection
    get :historical, on: :member
  end

  get '/datatables-spanish', to: 'welcome#datatables_spanish', as: :spanish_datatables
  get '/dashboard', to: 'dashboard#index', as: :dashboard
  patch '/dashboard/update_password', to: 'dashboard#update_password', as: :update_password_dashboard
  post '/dashboard/announcements/hide', to: 'dashboard#hide', as: :hide_announcement

  post '/dbf/:model/import', to: 'dbf#import', constraints: { model: /(buildings|departments|users|accounts|auxiliaries|assets)/ }, as: 'import_dbf'
  get '/dbf/:model', to: 'dbf#index', constraints: { model: /(buildings|departments|users|accounts|auxiliaries|assets)/ }, as: 'dbf'
  get '/dbf', to: redirect("#{ Rails.application.config.action_controller.relative_url_root }/dbf/buildings"), as: 'migration'

  devise_for :users, controllers: { sessions: "sessions" }, skip: [ :sessions ]
  as :user do
    get '/login' => 'sessions#new', as: :new_user_session
    post '/login' => 'sessions#create', as: :user_session
    delete '/logout' => 'sessions#destroy', as: :destroy_user_session
  end

  resources :welcome, only: [:index]

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'users#welcome'
end
