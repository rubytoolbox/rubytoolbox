# frozen_string_literal: true

class BlogController < ApplicationController
  BLOG = Blog.new(root: Rails.root.join("app", "blog_posts"), cache: Rails.env.production?)

  def index
    @posts = BLOG.posts
    respond_to do |format|
      format.html
      format.rss
    end
  end

  def show
    @post = BLOG.find(params[:id])
  end
end
