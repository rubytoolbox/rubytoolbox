# frozen_string_literal: true

class WelcomeController < ApplicationController
  def home
    @featured_categories = Category.featured
    @new_categories = Category.recently_added
    @trending_projects = Rubygem::Trend.latest.limit(8)
    @stats = Stats.new
    @recent_posts = BlogController::BLOG.recent_posts.presence
  end
end
