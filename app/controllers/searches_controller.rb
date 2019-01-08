# frozen_string_literal: true

class SearchesController < ApplicationController
  def show
    @query = params[:q].presence
    @search = Search.new(@query, order: current_order) if @query
  end

  private

  def current_order
    @current_order ||= Project::Order.new order: params[:order], directions: Project::Order::SEARCH_DIRECTIONS
  end
  helper_method :current_order
end
