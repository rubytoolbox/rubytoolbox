# frozen_string_literal: true

class SearchesController < ApplicationController
  def show
    @query = params[:q].presence
    return unless @query

    @search = Search.new(@query, order: current_order, show_forks: show_forks?)
    @projects = @search.projects.page(params[:page])
  end

  private

  def show_forks?
    params[:show_forks].present?
  end

  def current_order
    @current_order ||= Project::Order.new order: params[:order], directions: Project::Order::SEARCH_DIRECTIONS
  end
  helper_method :current_order
end
