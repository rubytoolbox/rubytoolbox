# frozen_string_literal: true

class WelcomeController < ApplicationController
  def home
    @featured_categories = Category.featured
    @stats = Stats.new
    @recent_posts = BlogController::BLOG.recent_posts.presence
  end
end
