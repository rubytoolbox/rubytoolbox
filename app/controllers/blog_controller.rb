# frozen_string_literal: true

class BlogController < ApplicationController
  BLOG = Blog.new(root: Rails.root.join("app", "blog_posts"), cache: Rails.env.production?)

  def index
    @posts = BLOG.posts
  end

  def show
    @post = BLOG.find(params[:id])
  end
end
