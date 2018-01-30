# frozen_string_literal: true

require "patterns"

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :categories, only: %i[show]
  resources :projects, only: %i[show], constraints: { id: Patterns::ROUTE_PATTERN }
  resource  :search, only: %i[show]
  resources :blog, only: %i[index show], constraints: { id: /[^\.]+/ }

  root "welcome#home"
end
