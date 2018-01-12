# frozen_string_literal: true

require "patterns"

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :categories, only: %i[show]
  resources :projects, only: %i[show], constraints: { id: Patterns::ROUTE_PATTERN }

  root "welcome#home"
end
