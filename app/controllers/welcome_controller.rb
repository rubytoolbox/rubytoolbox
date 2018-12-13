# frozen_string_literal: true

class WelcomeController < ApplicationController
  def home
    @featured_categories = Category.featured
  end
end
