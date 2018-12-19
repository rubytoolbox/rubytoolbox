# frozen_string_literal: true

class CategoriesController < ApplicationController
  def show
    @category = Category.find_for_show! params[:id], order: current_order
    redirect_to @category if @category.permalink != params[:id]
  end

  private

  def current_order
    @current_order ||= Project::Order.new order: params[:order]
  end
  helper_method :current_order
end
