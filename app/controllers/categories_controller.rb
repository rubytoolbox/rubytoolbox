# frozen_string_literal: true

class CategoriesController < ApplicationController
  def show
    @category = Category.find_for_show! params[:id], order_by: order_by
    redirect_to @category if @category.permalink != params[:id]
  end

  private

  ORDER_BY = {
    "rubygem_downloads"                       => "rubygems.downloads DESC NULLS LAST",
    "rubygem_reverse_dependencies_count"      => "rubygems.reverse_dependencies_count DESC NULLS LAST",
    "rubygem_first_release_on"                => "rubygems.first_release_on ASC NULLS LAST",
    "rubygem_latest_release_on"               => "rubygems.latest_release_on DESC NULLS LAST",
    "rubygem_releases_count"                  => "rubygems.releases_count DESC NULLS LAST",
    "github_repo_stargazers_count"            => "github_repos.stargazers_count DESC NULLS LAST",
    "github_repo_forks_count"                 => "github_repos.forks_count DESC NULLS LAST",
    "github_repo_watchers_count"              => "github_repos.watchers_count DESC NULLS LAST",
    "github_repo_average_recent_committed_at" => "github_repos.average_recent_committed_at DESC NULLS LAST",
  }.freeze

  def current_order
    ORDER_BY.key?(params[:order]) ? params[:order] : "score"
  end

  helper_method :current_order

  def order_by
    ORDER_BY[current_order] || "projects.score DESC NULLS LAST"
  end
end
