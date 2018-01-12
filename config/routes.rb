# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Ripped from https://github.com/rubygems/rubygems.org/blob/master/lib/patterns.rb and enhanced
  # to also allow slashes as per github
  SPECIAL_CHARACTERS    = ".-_/"
  ALLOWED_CHARACTERS    = "[A-Za-z0-9#{Regexp.escape(SPECIAL_CHARACTERS)}]+"
  ROUTE_PATTERN         = /#{ALLOWED_CHARACTERS}/

  resources :categories, only: %i[show]
  resources :projects, only: %i[show], constraints: { id: ROUTE_PATTERN }

  root "welcome#home"
end
