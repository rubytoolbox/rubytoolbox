# frozen_string_literal: true

class SearchesController < ApplicationController
  def show
    @query = params[:q].presence
    return unless @query

    @search = Search.new(@query, order: current_order, show_forks: show_forks?)
    @projects = @search.projects.page(params[:page])

    redirect_to_search_with_forks_included if !@search.show_forks && @projects.empty?
  end

  private

  def redirect_to_search_with_forks_included
    redirect_to action:     :show,
                q:          @search.query,
                order:      current_order.ordered_by,
                show_forks: true
  end

  def show_forks?
    params[:show_forks].present?
  end

  def current_order
    @current_order ||= Project::Order.new order: params[:order], directions: Project::Order::SEARCH_DIRECTIONS
  end
  helper_method :current_order
end
