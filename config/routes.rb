Rails.application.routes.draw do
  ActiveAdmin.routes(self)

  root 'pages#home'

  # Health check endpoint
  get '/up', to: 'application#up'

  devise_for :users, path: '', path_names: { sign_in: 'login', sign_up: 'signup' }, controllers: { registrations: 'registrations' }
  get 'logout', to: 'pages#logout', as: 'logout'

  resources :subscribe, only: [:index]
  resources :dashboard, only: [:index]
  resources :account, only: %i[index update] do
    get :stop_impersonating, on: :collection
  end
  resources :billing_portal, only: [:new, :create]
  resources :blog_posts, controller: :blog_posts, path: "blog", param: :slug

  # Feedback matrix
  get '/matrix', to: 'feedbacks#matrix'
  get '/heat-map', to: 'feedbacks#heat_map'

  # Invite routes
  resources :invites, only: :create do
    get 'claim/:token', on: :collection, action: :claim, as: :claim
  end

  # static pages
  pages = %w[
    privacy terms
  ]

  pages.each do |page|
    get "/#{page}", to: "pages##{page}", as: page.gsub('-', '_').to_s
  end

  # admin panels
  authenticated :user, lambda(&:admin?) do
    # insert sidekiq etc
    mount Split::Dashboard, at: 'admin/split'
  end
end
