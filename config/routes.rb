# frozen_string_literal: true

require "patterns"
require "sidekiq/web"

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :categories, only: %i[index show]
  resources :projects, only: %i[show], constraints: { id: Patterns::ROUTE_PATTERN } do
  end
  get "compare(/:id)", to: "comparisons#show", constraints: { id: /.*/ }, as: :comparison

  resource  :search, only: %i[show]
  resources :blog, only: %i[index show], constraints: { id: /[^\.]+/ }

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

  root "welcome#home"
end
