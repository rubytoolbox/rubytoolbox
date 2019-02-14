# frozen_string_literal: true

class SearchesController < ApplicationController
  def show
    @query = params[:q].presence
    return unless @query

    perform_search

    redirect_to_search_with_forks_included if should_redirect_to_included_forks?
  end

  def by_name
    render json: Project.suggest(params[:q])
  end

  private

  def perform_search
    @search = Search.new @query, order: current_order, show_forks: show_forks?
    @projects = @search.projects.page params[:page]
    @display_mode = DisplayMode.new params[:display], default: "compact"
  end

  # If a user searches for some query but that search does not
  # yield any project results we automatically redirect to the
  # search with bugfix forks included. However this must only
  # happen if the show forks param is not set at all, otherwise
  # it becomes impossible to reduce the query back to "without forks" :)
  def should_redirect_to_included_forks?
    !show_forks? && !params.key?(:show_forks) && @projects.empty?
  end

  def redirect_to_search_with_forks_included
    redirect_to action:     :show,
                q:          @search.query,
                order:      current_order.ordered_by,
                show_forks: true
  end

  def show_forks?
    params[:show_forks].present? && params[:show_forks] == "true"
  end

  def current_order
    @current_order ||= Project::Order.new order: params[:order], directions: Project::Order::SEARCH_DIRECTIONS
  end
  helper_method :current_order
end
