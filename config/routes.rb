# frozen_string_literal: true

require "patterns"
require "sidekiq/web"

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  namespace :api do
    namespace :projects do
      get "compare(/:id)", to: "comparisons#show", constraints: { id: /.*/ }
    end
  end

  resources :blog, only: %i[index show], constraints: { id: /[^\.]+/ }
  resources :categories, only: %i[index show]

  resources :projects, only: %i[show], constraints: { id: Patterns::ROUTE_PATTERN }
  get "compare(/:id)", to: "comparisons#show", constraints: { id: /.*/ }, as: :comparison
  resources :trends, only: %i[index show]

  resource :search, only: %i[show] do
    collection do
      get :by_name
    end
  end

  namespace :webhooks do
    post "github", to: "github#create", defaults: { formats: :json }
  end

  Sidekiq::Web.use Rack::Auth::Basic do |_username, password|
    ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(password),
      ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"].presence || SecureRandom.hex(128))
    )
  end
  mount Sidekiq::Web, at: "/ops/sidekiq"
  mount PgHero::Engine, at: "/ops/pghero" if Rails.env.development?

  root "welcome#home"
end
